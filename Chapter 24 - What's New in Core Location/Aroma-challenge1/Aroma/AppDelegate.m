//
//  AppDelegate.m
//  Aroma
//
//  Created by Chris Wagner on 8/3/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "RestaurantDetailService.h"
#import "Restaurant.h"
#import "BeaconMonitoringService.h"

#import "RestaurantDetailViewController.h"

@interface AppDelegate () <CLLocationManagerDelegate>

@end

@implementation AppDelegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        Restaurant *restaurant = [[RestaurantDetailService sharedService] restaurantWithUUID:beaconRegion.proximityUUID];
        if (restaurant) {
            NSDictionary *userInfo = @{@"restaurant": restaurant, @"state": @(state)};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidDetermineRegionState" object:self userInfo:userInfo];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        Restaurant *restaurant = [[RestaurantDetailService sharedService] restaurantWithUUID:beaconRegion.proximityUUID];
        if (restaurant) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.userInfo = @{@"uuid": restaurant.uuid.UUIDString};
            notification.alertBody = [NSString stringWithFormat:@"Smell that? Looks like you're near %@!", restaurant.name];
            notification.soundName = @"Default";
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidEnterRegion" object:self userInfo:@{@"restaurant": restaurant}];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        Restaurant *restaurant = [[RestaurantDetailService sharedService] restaurantWithUUID:beaconRegion.proximityUUID];
        if (restaurant) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.alertBody = [NSString stringWithFormat:@"We hope you enjoyed the smells and more of %@. See you next time!", restaurant.name];
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidExitRegion" object:self userInfo:@{@"restaurant": restaurant}];
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[BeaconMonitoringService sharedInstance] stopMonitoringAllRegions];
    NSArray *restaurants = [[RestaurantDetailService sharedService] restaurants];
    for (Restaurant *restaurant in restaurants) {
        [[BeaconMonitoringService sharedInstance] startMonitoringBeaconWithUUID:restaurant.uuid major:0 minor:0 identifier:restaurant.name onEntry:YES onExit:YES];
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    return YES;
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

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:notification.userInfo[@"uuid"]];
    Restaurant *restaurant = [[RestaurantDetailService sharedService] restaurantWithUUID:uuid];
    if (restaurant) {
        RestaurantDetailViewController *restaurantDetailViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"RestaurantDetailViewController"];
        restaurantDetailViewController.restaurant = restaurant;

        UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
        MainViewController *mainViewController = (MainViewController *)navController.topViewController;
        [mainViewController scrollToRestaurant:restaurant];
    }
}


@end
