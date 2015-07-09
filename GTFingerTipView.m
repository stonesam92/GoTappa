#import "GTFingerTipView.h"

#define IMAGE_PATH @"/Library/Application Support/GoTappa/tapper.png"

@implementation GTFingerTipView
+ (UIImage *)image {
    static UIImage *touchImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        touchImage = [[UIImage imageWithContentsOfFile:IMAGE_PATH] retain];
    });
        
    return touchImage;
}

- (instancetype)init {
    self = [super initWithImage:[GTFingerTipView image]];
    self.alpha = 0.9;
    return self;
}
@end
