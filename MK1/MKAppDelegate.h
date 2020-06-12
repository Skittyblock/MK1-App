// MKAppDelegate.h

#import <UIKit/UIKit.h>

@interface MKAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection;

@end

