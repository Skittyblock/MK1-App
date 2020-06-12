// UIBackgroundStyle.h

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UIBackgroundStyle) {
    UIBackgroundStyleDefault,
    UIBackgroundStyleTransparent,
    UIBackgroundStyleExtraLightBlur,
    UIBackgroundStyleLightBlur,
    UIBackgroundStyleDarkBlur,
    UIBackgroundStyleDarkTranslucent,
    UIBackgroundStyleBlur
};

@interface UIApplication (UIBackgroundStyle)
- (void)_setBackgroundStyle:(UIBackgroundStyle)style;
@end
