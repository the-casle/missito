#import "MISAppDelegate.h"
#import "MISRootViewController.h"
#import "MISImportController.h"
#import "MISExportViewController.h"

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
    
    _importController = [[UINavigationController alloc] initWithRootViewController:[[MISImportController alloc] init]];
    if (@available(iOS 11, tvOS 11, *)) {
        _importController.navigationBar.prefersLargeTitles = UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad ? YES : NO;
    }
    _importController.title = @"Import";
    _importController.view.backgroundColor = [UIColor whiteColor];
    [localViewControllersArray addObject:_importController];
    
    _exportController = [[UINavigationController alloc] initWithRootViewController:[[MISExportViewController alloc] init]];
    if (@available(iOS 11, tvOS 11, *)) {
        _exportController.navigationBar.prefersLargeTitles = UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad ? YES : NO;
    }
    _exportController.title = @"Export";
    _exportController.view.backgroundColor = [UIColor whiteColor];
    [localViewControllersArray addObject:_exportController];
    
    
    tabBars.viewControllers = localViewControllersArray;
    tabBars.view.autoresizingMask=(UIViewAutoresizingFlexibleHeight);
    _window.rootViewController = tabBars;
    [_window makeKeyAndVisible];
    
}


@end
