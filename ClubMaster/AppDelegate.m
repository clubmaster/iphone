//
//  AppDelegate.m
//  ClubMaster
//
//  Created by Henrik Hansen on 15/11/11.
//

#import "AppDelegate.h"

#import "MyTrainingViewController.h"
#import "SettingsViewController.h"
#import "LoginViewController.h"
#import "EventsViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    UIViewController *myTrainingViewController = [[[MyTrainingViewController alloc] initWithNibName:@"MyTrainingViewController" bundle:nil] autorelease];
    UINavigationController *viewController1 = [[[UINavigationController alloc] initWithRootViewController:myTrainingViewController] autorelease];

    UIViewController *eventsView = [[[EventsViewController alloc] initWithNibName:@"EventsViewController" bundle:nil] autorelease];
    UINavigationController *viewController2 = [[[UINavigationController alloc] initWithRootViewController:eventsView] autorelease];

    UIViewController *settingsView = [[[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil] autorelease];
    UINavigationController *viewController3 = [[[UINavigationController alloc] initWithRootViewController:settingsView] autorelease];

    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:viewController1, viewController2, viewController3, nil];

    self.window.rootViewController = self.tabBarController;

    [self.window makeKeyAndVisible];

    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    [self.tabBarController presentModalViewController:loginViewController animated:NO];
    [loginViewController release];

    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
