//
//  AppDelegate.m
//  TwitterApp
//
//  Created by Diana Stefania Daia on 18/04/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "ViewController.h"
#import "MyProfileViewController.h"
#import "SearchViewController.h"
#import "MyProfileViewController.h"
#import "SearchViewController.h"
#import "FollowViewController.h"
#import "LoginViewController.h"
#import "Utils.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"1Znj9IrJG6WhBlbCVWj3TsRPtkyrpU7Aq7vWDkqb"
                  clientKey:@"SOmIUdsTBqd4EHPuee2PgzkbeIJ2Q8UwrduzMPR6"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.tabBarController = [[UITabBarController alloc] init];
    
    ViewController *timeline = [[ViewController alloc] init];
    MyProfileViewController *myProfile = [[MyProfileViewController alloc] init];
    SearchViewController *search = [[SearchViewController alloc] init];
    FollowViewController *follow = [[FollowViewController alloc] init];
    
    UINavigationController *userProfileNavController = [[UINavigationController alloc] initWithRootViewController:follow];
    UINavigationController *myProfileNavController = [[UINavigationController alloc] initWithRootViewController:myProfile];
    UINavigationController *searchNavController = [[UINavigationController alloc] initWithRootViewController:search];
    
    NSArray* controllers = [NSArray arrayWithObjects:timeline, myProfileNavController, searchNavController, userProfileNavController, nil];
    self.tabBarController.viewControllers = controllers;
    self.tabBarController.tabBar.tintColor = [Utils colorFromHex:@"#8471BA"];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"AmericanTypewriter" size:20.0f], UITextAttributeFont, nil] forState:UIControlStateNormal];
    
    [[self.tabBarController.tabBar.items objectAtIndex:0] setTitle:@"Timeline"];
    
    
    [[self.tabBarController.tabBar.items objectAtIndex:1] setTitle:@"Me"];
    
    
    [[self.tabBarController.tabBar.items objectAtIndex:2] setTitle:@"Search"];
    
    [[self.tabBarController.tabBar.items objectAtIndex:3] setTitle:@"Follow"];
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedIn"])
    {
        self.window.rootViewController = self.tabBarController;
    }
    else
    {
        self.window.rootViewController = [[LoginViewController alloc] init];
    }
    
    
    
    [self.window makeKeyAndVisible];

    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
