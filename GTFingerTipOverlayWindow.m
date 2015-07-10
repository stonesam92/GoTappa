#import "GTFingerTipOverlayWindow.h"

@interface GTFingerTipOverlayWindow ()
@property (nonatomic) NSTimer *removeViewTimer;
@end

@implementation GTFingerTipOverlayWindow

// UIKit tries to get the rootViewController from the overlay window.
// Instead, try to find the rootViewController on some other application window.
// Fixes problems with status bar hiding, because it considers the overlay window a candidate for controlling the status bar.

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _removeViewTimer = [[NSTimer scheduledTimerWithTimeInterval:5.0
                                                            target:self
                                                          selector:@selector(removeSubviews:)
                                                          userInfo:nil
                                                           repeats:YES] retain];
    }
    return self;
}

- (void)dealloc {
    [self.removeViewTimer release];
    [super dealloc];
}

- (void)removeSubviews:(NSTimer *)sender {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (UIViewController *)rootViewController
{
    NSLog(@"entering getrootView");
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (self == window || ![window isKeyWindow])
            continue;

        UIViewController *realRootViewController = window.rootViewController;
        if (realRootViewController != nil)
            NSLog(@"exiting getrootView");
            return realRootViewController;
    }
    return [super rootViewController];
}

@end

