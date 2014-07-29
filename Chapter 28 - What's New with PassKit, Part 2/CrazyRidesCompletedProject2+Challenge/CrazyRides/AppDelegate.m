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
    /* handle app launch from URL */
    if (launchOptions[UIApplicationLaunchOptionsURLKey]) {
        
        [self handleURL: launchOptions[UIApplicationLaunchOptionsURLKey]
               userInfo:launchOptions[UIApplicationLaunchOptionsAnnotationKey]
         ];
        
    }
    
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url sourceApplication:(NSString *) sourceApplication annotation:(id)annotation
{
    /* if app is awakend from a pass, go to booking screen */
    [self handleURL: url userInfo: annotation];
    return YES;
}

/* if app is launched from a pass, go to booking screen */
-(void)handleURL:(NSURL*)url userInfo:(NSDictionary*)info
{
    if ([url.host isEqualToString:@"bookseat"] && info!=nil) {
        //persist the ride name
        self.bookingSeatOnRide = info[@"sourcePassRide"];
        
        //open the book ride screen, and let it handle the booking
        UIApplication* app = [UIApplication sharedApplication];
        UINavigationController* navigationCtr =
        (UINavigationController*)app.keyWindow.rootViewController;
        [navigationCtr popToRootViewControllerAnimated:NO];
        [navigationCtr.topViewController
         performSegueWithIdentifier:@"bookRide" sender:nil];
    }
}


@end