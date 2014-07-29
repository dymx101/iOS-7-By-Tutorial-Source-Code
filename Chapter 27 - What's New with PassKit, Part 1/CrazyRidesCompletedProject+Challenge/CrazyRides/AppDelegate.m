//
//  AppDelegate.m
//  CrazyRides
//
//  Created by Marin Todorov on 6/22/13.
//  Terms apply, source code provided with "iOS7 by Tutorials"
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    /* check if all configuration is properly done */
    NSDictionary *passData = [NSDictionary dictionaryWithContentsOfFile:
                              [[NSBundle mainBundle] pathForResource:@"bf3monthspass" ofType:@"plist"]
                              ];
    
    if ([passData[@"teamIdentifier"] length]<10 || [passData[@"passTypeIdentifier"] length]<5) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"bf3monthspass.plist is empty, fill in your data!" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil] show];
    }
    
    //config check finished
    
    return YES;
}

@end