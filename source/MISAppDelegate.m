#import "MISAppDelegate.h"
#import "MISRootViewController.h"
#import "MISViewController.h"

@implementation MISAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    UITabBarController *tabBars = [[UITabBarController alloc] init];
    NSMutableArray *localViewControllersArray = [[NSMutableArray alloc] initWithCapacity:1];
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    _rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MISRootViewController alloc] init]];
    if (@available(iOS 11, tvOS 11, *)) {
        _rootViewController.navigationBar.prefersLargeTitles = UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad ? YES : NO;
    }
    //_rootViewController.tabBarItem.image=[UIImage imageNamed:@"save.png"];
    
    [localViewControllersArray addObject:_rootViewController];
    
    _viewController = [[UINavigationController alloc] initWithRootViewController:[[MISViewController alloc] init]];
    if (@available(iOS 11, tvOS 11, *)) {
        _viewController.navigationBar.prefersLargeTitles = UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad ? YES : NO;
    }
    _viewController.view.backgroundColor = [UIColor blueColor];
     [localViewControllersArray addObject:_viewController];
    
    tabBars.viewControllers = localViewControllersArray;
    tabBars.view.autoresizingMask=(UIViewAutoresizingFlexibleHeight);
    _window.rootViewController = tabBars;
    [_window makeKeyAndVisible];
    
}


@end
