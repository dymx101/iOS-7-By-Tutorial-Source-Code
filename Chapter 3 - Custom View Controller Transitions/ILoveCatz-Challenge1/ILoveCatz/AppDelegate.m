//
//  AppDelegate.m
//  ILoveCatz
//
//  Created by Colin Eberhardt on 22/08/2013.
//  Copyright (c) 2013 com.razeware. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "Cat.h"

@implementation AppDelegate {
    NSArray *_cats;
}

- (NSArray *)cats {
    return _cats;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    _cats = @[
        [Cat catWithImage:@"CatInBin.jpg" title:@"Cat in a bin" attribution:@"http://www.sxc.hu/photo/1406907"],
        [Cat catWithImage:@"DancingCat.jpg" title:@"Dancing cat" attribution:@"http://www.sxc.hu/photo/1378836"],
        [Cat catWithImage:@"KittensInABasket.jpg" title:@"Kittens in a basket" attribution:@"http://www.sxc.hu/photo/1178601"],
        [Cat catWithImage:@"RelaxedCat.jpg" title:@"Relaxed cat" attribution:@"http://www.sxc.hu/photo/1361582"],
        [Cat catWithImage:@"VeryYoungKitten.jpg" title:@"Very young kitten" attribution:@"http://www.sxc.hu/photo/235473"],
        [Cat catWithImage:@"YawningCat.jpg" title:@"Yawning cat" attribution:@"http://www.sxc.hu/photo/1353556"],
        [Cat catWithImage:@"CuteKitten.jpg" title:@"Cute kitten" attribution:@"http://www.sxc.hu/photo/1319510"]
    ];
    
    // style the navigation bar
    UIColor* navColor = [UIColor colorWithRed:0.97f green:0.37f blue:0.38f alpha:1.0f];
    [[UINavigationBar appearance] setBarTintColor:navColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    // make the status bar white
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    return YES;
}


@end
