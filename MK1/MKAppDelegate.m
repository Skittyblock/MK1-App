// MKAppDelegate.m

#import "MKAppDelegate.h"
#import "MKScriptsViewController.h"
#import "MKConsoleViewController.h"
#import "UIBackgroundStyle.h"
#import "CPDistributedMessagingCenter.h"
#import <rocketbootstrap/rocketbootstrap.h>

@implementation MKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    MKScriptsViewController *scriptsViewController = [[MKScriptsViewController alloc] init];
    scriptsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Scripts" image:[UIImage imageNamed:@"archivebox"] tag:0];
    UINavigationController *scriptsNavController = [[UINavigationController alloc] initWithRootViewController:scriptsViewController];
    
    MKConsoleViewController *consoleViewController = [[MKConsoleViewController alloc] init];
    consoleViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Console" image:[UIImage imageNamed:@"doc.plaintext"] tag:0];
    UINavigationController *consoleNavController = [[UINavigationController alloc] initWithRootViewController:consoleViewController];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[scriptsNavController, consoleNavController];
    
    [self.window setRootViewController:scriptsNavController]; //tabBarController;
    [self.window makeKeyAndVisible];
    
    self.window.backgroundColor = [UIColor clearColor];
    
    [self traitCollectionDidChange:nil];
    
    return YES;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if (@available(iOS 13.0, *)) {
        if (self.window.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            [[UIApplication sharedApplication] _setBackgroundStyle:UIBackgroundStyleDarkBlur];
        } else {
            [[UIApplication sharedApplication] _setBackgroundStyle:UIBackgroundStyleExtraLightBlur];
        }
    } else {
        [[UIApplication sharedApplication] _setBackgroundStyle:UIBackgroundStyleLightBlur];
    }
}

// URL scheme
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    if (![url.scheme isEqualToString:@"mk1"]) return NO;

    NSDictionary *userInfo;
    if (url.pathComponents.count > 2) {
        userInfo = @{@"name": url.pathComponents[1], @"arg": url.lastPathComponent};
    } else {
        userInfo = @{@"name": url.lastPathComponent};
    }

    if ([url.host.lowercaseString isEqualToString:@"runscript"]) { // Run script
#if !TARGET_OS_SIMULATOR
        static CPDistributedMessagingCenter *c = nil;
        c = [CPDistributedMessagingCenter centerNamed:@"xyz.skitty.mk1"];
        rocketbootstrap_distributedmessagingcenter_apply(c);
        [c sendMessageName:@"runscript" userInfo:userInfo];
#endif
    } else if([url.host.lowercaseString isEqualToString:@"runtrigger"]) { // Run trigger
#if !TARGET_OS_SIMULATOR
        static CPDistributedMessagingCenter *c = nil;
        c = [CPDistributedMessagingCenter centerNamed:@"xyz.skitty.mk1"];
        rocketbootstrap_distributedmessagingcenter_apply(c);
        [c sendMessageName:@"runtrigger" userInfo:userInfo];
#endif
    } else if([url.host.lowercaseString isEqualToString:@"ext-script"]) { // Download external script
        //[self handleExternalScript:url];
    }

    // Shortcuts callback
    if (options && options[UIApplicationOpenURLOptionsSourceApplicationKey] && [options[UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.apple.shortcuts"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"shortcuts://callback"] options:@{} completionHandler:nil];
    }

    return YES;
}

@end
