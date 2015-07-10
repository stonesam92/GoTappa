#import <UIKit/UIKit.h>
#import "GTFingerTipView.h"
#import "GTFingerTipOverlayWindow.h"

#define FADE_DURATION 0.2
#define PREFS_LOCATION @"/var/mobile/Library/Preferences/com.samstone.gotappa.plist"

static BOOL fingerTipRemovalScheduled;

@interface UIWindow ()
- (UIWindow *)overlayWindow;
- (void)scheduleFingerTipRemoval;
- (void)cancelScheduledFingerTipRemoval;
- (void)removeInactiveFingerTips;
- (void)removeFingerTipWithHash:(NSUInteger)hash;
- (BOOL)shouldAutomaticallyRemoveFingerTipForTouch:(UITouch *)touch;
@end

%group MainGroup

%hook UIWindow
%new
- (UIWindow *)overlayWindow
{
    static UIWindow *overlayWindow = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        overlayWindow = [[GTFingerTipOverlayWindow alloc] initWithFrame:self.frame];
        
        overlayWindow.userInteractionEnabled = NO;
        overlayWindow.windowLevel = UIWindowLevelStatusBar;
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.hidden = NO;
    });
    
    return overlayWindow;
}

#pragma mark UIWindow overrides

- (void)sendEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    
    for (UITouch *touch in [allTouches allObjects])
    {
        switch (touch.phase)
        {
            case UITouchPhaseBegan:
            case UITouchPhaseMoved:
            case UITouchPhaseStationary:
            {
                GTFingerTipView *touchView = (GTFingerTipView *)[[self overlayWindow] viewWithTag:touch.hash];

                if (touch.phase != UITouchPhaseStationary && touchView != nil && [touchView isFadingOut])
                {
                    [touchView removeFromSuperview];
                    touchView = nil;
                }
                
                if (touchView == nil && touch.phase != UITouchPhaseStationary)
                {
                    touchView = [[GTFingerTipView alloc] init];
                    [[self overlayWindow] addSubview:touchView];
                    [touchView release];
                }
        
                if ( ! [touchView isFadingOut])
                {
                    touchView.center = [touch locationInView:[self overlayWindow]];
                    touchView.tag = touch.hash;
                    touchView.timestamp = touch.timestamp;
                    touchView.shouldAutomaticallyRemoveAfterTimeout = [self shouldAutomaticallyRemoveFingerTipForTouch:touch];
                }
                break;
            }

            case UITouchPhaseEnded:
            case UITouchPhaseCancelled:
            {
                [self removeFingerTipWithHash:touch.hash];
                break;
            }
        }
    }
        
    [self scheduleFingerTipRemoval]; 
    
    %orig;
}

#pragma mark Fingertip View Handling

%new
- (void)scheduleFingerTipRemoval
{
    if (fingerTipRemovalScheduled)
        return;
    
    fingerTipRemovalScheduled = YES;
    [self performSelector:@selector(removeInactiveFingerTips) withObject:nil afterDelay:0.1];
}

%new
- (void)cancelScheduledFingerTipRemoval
{
    fingerTipRemovalScheduled = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeInactiveFingerTips) object:nil];
}

%new
- (void)removeInactiveFingerTips
{
    fingerTipRemovalScheduled = NO;

    NSTimeInterval now = [[NSProcessInfo processInfo] systemUptime];
    const CGFloat REMOVAL_DELAY = 0.2;

    for (GTFingerTipView *touchView in [[self overlayWindow] subviews])
    {
        if ( ! [touchView isKindOfClass:[GTFingerTipView class]])
            continue;
        
        if (touchView.shouldAutomaticallyRemoveAfterTimeout && now > touchView.timestamp + REMOVAL_DELAY)
            [self removeFingerTipWithHash:touchView.tag];
    }

    if ([[[self overlayWindow] subviews] count] > 0)
        [self scheduleFingerTipRemoval];
}

%new
- (void)removeFingerTipWithHash:(NSUInteger)hash
{
    GTFingerTipView *touchView = (GTFingerTipView *)[[self overlayWindow] viewWithTag:hash];
    BOOL animationsWereEnabled = [UIView areAnimationsEnabled];
    if ( ! [touchView isKindOfClass:[GTFingerTipView class]])
        return;
    
    if ([touchView isFadingOut])
        return;
        
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:FADE_DURATION
                          delay:0.1
                        options:0
                     animations:^{
                            touchView.frame = CGRectMake(
                                    touchView.center.x - touchView.frame.size.width * 1.2 / 2, 
                                    touchView.center.y - touchView.frame.size.height * 1.2 / 2, 
                                    touchView.frame.size.width  * 1.2, 
                                    touchView.frame.size.height * 1.2);
                            
                            touchView.alpha = 0.0;
                         }
                     completion:^(BOOL finished){
                        [UIView setAnimationsEnabled:animationsWereEnabled];
                        touchView.fadingOut = YES;
                        [touchView removeFromSuperview];
                    }];
}

%new
- (BOOL)shouldAutomaticallyRemoveFingerTipForTouch:(UITouch *)touch
{
    UIView *view = [touch view];
    view = [view hitTest:[touch locationInView:view] withEvent:nil];

    if ([[touch gestureRecognizers] count] == 0)
        return YES;

    while (view != nil)
    {
        if ([view isKindOfClass:[UITableViewCell class]])
        {
            for (UIGestureRecognizer *recognizer in [touch gestureRecognizers])
            {
                if ([recognizer isKindOfClass:[UISwipeGestureRecognizer class]])
                    return YES;
            }
        }
        view = view.superview;
    }

    return NO;
}
%end

%end

%ctor {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PREFS_LOCATION];
    NSString *bundleID = [NSBundle mainBundle].bundleIdentifier;
    NSLog(@"running in %@", bundleID);
    if (!prefs || (
                [prefs[@"enabled"] boolValue] &&
                ![bundleID isEqualToString:@"com.apple.camera"])) {
        %init(MainGroup);
    } 
}

