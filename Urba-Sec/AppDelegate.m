//
//  AppDelegate.m
//  Urba-Sec
//
//  Created by Ricardo Nazario on 11/25/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "AppDelegate.h"
#import "UBLogInViewController.h"
#import "UBVisitorFeedViewController.h"
#import "UBNavViewController.h"
#import "ActivityView.h"

@import Firebase;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [FIRApp configure];
    
    UIColor *urbaGreen = [UIColor colorWithRed:0.0/255.0 green:190.0/255.0 blue:58.0/255.0 alpha:1];
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setBarTintColor:urbaGreen];
    [[UINavigationBar appearance] setClipsToBounds:YES];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UITabBar appearance] setBarTintColor:urbaGreen];
    [[UITabBar appearance] setClipsToBounds:YES];
    
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *auth, FIRUser *user) {
        
        [ActivityView loadSpinnerIntoView:self.window.rootViewController.view];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        if (user) {
            
            FIRDatabaseReference *ref = [[[FIRDatabase database] reference] child:@"security"];
            FIRDatabaseQuery *query = [[ref queryOrderedByChild:@"email" ] queryEqualToValue:[FIRAuth auth].currentUser.email];
            
            [query observeEventType:FIRDataEventTypeValue
                          withBlock:^(FIRDataSnapshot *snapshot) {
                              
                              // If logging user exits in one unit or more...
                              if ([snapshot exists]) {
                                  
                                  NSLog(@"SNapshot exists");
                                  
                                  // Go to home view (NSUserDefaults has the current unit)
                                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                  NSDictionary *secDict = [defaults objectForKey:@"currentSec"];
                                  UBNavViewController *navView = [storyboard instantiateViewControllerWithIdentifier:@"NavView"];
                                  UBVisitorFeedViewController *mainView = (UBVisitorFeedViewController *)[navView topViewController];
                                  if (snapshot.childrenCount == 1) {
                                      for (FIRDataSnapshot *snap in snapshot.children) {
                                          secDict = [NSDictionary dictionaryWithObjectsAndKeys:snap.key,@"id", snap.value, @"values", nil];
                                      }
                                      [mainView setSecDict:secDict];
                                      [self.window.rootViewController presentViewController:navView animated:YES completion:nil];
                                  }
                              } else {
                                  NSLog(@"No snaps");
                              }
                          }];
        } else {
        
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:nil forKey:@"currentCommunity"];
            UBLogInViewController *ulvc = [storyboard instantiateInitialViewController];
            [self.window.rootViewController presentViewController:ulvc animated:YES completion:nil];
        }
    }];

    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
