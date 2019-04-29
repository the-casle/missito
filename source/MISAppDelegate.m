#import "MISAppDelegate.h"
#import "MISRootViewController.h"
#import "MISBundleViewController.h"

@implementation MISAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    UITabBarController *tabBars = [[UITabBarController alloc] init];
    NSMutableArray *localViewControllersArray = [[NSMutableArray alloc] initWithCapacity:1];
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    _rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MISRootViewController alloc] init]];
    _rootViewController.title = @"Preferences";
    if (@available(iOS 11, tvOS 11, *)) {
        _rootViewController.navigationBar.prefersLargeTitles = UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad ? YES : NO;
    }
    //_rootViewController.tabBarItem.image=[UIImage imageNamed:@"save.png"];
    
    [localViewControllersArray addObject:_rootViewController];
    
    _bundleViewController = [[UINavigationController alloc] initWithRootViewController:[[MISBundleViewController alloc] init]];
    if (@available(iOS 11, tvOS 11, *)) {
        _bundleViewController.navigationBar.prefersLargeTitles = UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad ? YES : NO;
    }
    _bundleViewController.title = @"Bundles";
    _bundleViewController.view.backgroundColor = [UIColor whiteColor];
    [localViewControllersArray addObject:_bundleViewController];
    
    tabBars.viewControllers = localViewControllersArray;
    tabBars.view.autoresizingMask=(UIViewAutoresizingFlexibleHeight);
    _window.rootViewController = tabBars;
    [_window makeKeyAndVisible];
    
}


@end
