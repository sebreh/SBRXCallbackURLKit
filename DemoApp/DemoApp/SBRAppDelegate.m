//
//  SBRAppDelegate.m
//  DemoApp
//
//  Created by Sebastian Rehnby on 8/8/13.
//  Copyright (c) 2013 Sebastian Rehnby. All rights reserved.
//

#import "SBRAppDelegate.h"
#import "SBRCallbackAction.h"

#import "SBRViewController.h"

@implementation SBRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
  self.viewController = [[SBRViewController alloc] initWithNibName:@"SBRViewController" bundle:nil];
  self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
  
  [[SBRCallbackParser sharedParser] setURLScheme:@"demoapp"];
  
  SBRCallbackAction *action = [SBRCallbackAction actionWithURLScheme:@"otherapp" name:@"drawSomething"];
  [action registerWithParser:[SBRCallbackParser sharedParser] successBlock:^(NSDictionary *parameters) {
    NSLog(@"Finished drawing");
  }];
  
  [action trigger];
  
  [[SBRCallbackParser sharedParser] addHandlerForActionName:@"myAction" handlerBlock:^BOOL(NSDictionary *parameters, NSString *source, SBRCallbackActionHandlerCompletionBlock completion) {
    NSLog(@"Action was called");
    
    return YES;
  }];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  return [[SBRCallbackParser sharedParser] handleURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
