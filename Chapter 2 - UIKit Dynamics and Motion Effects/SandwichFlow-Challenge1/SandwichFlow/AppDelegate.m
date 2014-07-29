//
//  AppDelegate.m
//  SandwichFlow
//
//  Created by Colin Eberhardt on 16/07/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
{
    NSArray* _sandwiches;
}

- (NSArray *)sandwiches {
    return _sandwiches;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self loadSandwiches];
    return YES;
}


- (void)loadSandwiches {
    NSString* path = [[NSBundle mainBundle] pathForResource: @"Sandwiches"
                                                     ofType: @"json"];
    NSString* data = [NSString stringWithContentsOfFile: path
                                               encoding: NSUTF8StringEncoding
                                                  error: nil];
    
    NSData* resultData = [data dataUsingEncoding:NSUTF8StringEncoding];
    _sandwiches = [NSJSONSerialization JSONObjectWithData:resultData
                                                       options:kNilOptions
                                                         error:nil];
}

@end
