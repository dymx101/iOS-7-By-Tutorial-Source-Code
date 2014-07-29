//
//  AppDelegate.m
//  ColloQR
//
//  Created by Matt Galloway on 20/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSURL *defaultsFileURL = [[NSBundle mainBundle] URLForResource:@"Defaults" withExtension:@"plist"];
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfURL:defaultsFileURL];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    return YES;
}

@end
