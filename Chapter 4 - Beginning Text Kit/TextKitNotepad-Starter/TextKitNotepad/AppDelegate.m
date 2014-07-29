//
//  CEAppDelegate.m
//  TextKitNotepad
//
//  Created by Colin Eberhardt on 19/06/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "AppDelegate.h"
#import "Note.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // create some notes!
    self.notes = [NSMutableArray arrayWithArray: @[
        [Note noteWithText:@"Shopping List\r\r1. Cheese\r2. Biscuits\r3. Sausages\r4. IMPORTANT Cash for going out!\r5. -potatoes-\r6. A copy of iOS6 by tutorials\r7. A new iPhone\r8. A present for mum"],
        [Note noteWithText:@"Meeting notes\rA long and drawn out meeting, it lasted hours and hours and hours!"],
        [Note noteWithText:@"Perfection ... \n\nPerfection is achieved not when there is nothing left to add, but when there is nothing left to take away - Antoine de Saint-Exupery"],
        [Note noteWithText:@"Notes on iOS7\nThis is a big change in the UI design, it's going to take a *lot* of getting used to!"],
        [Note noteWithText:@"Meeting notes\rA dfferent meeting, just as long and boring"],
        [Note noteWithText:@"A collection of thoughts\rWhy do birds sing? Why is the sky blue? Why is it so hard to create good test data?"]]];
    
    // style the navigation bar
    UIColor* navColor = [UIColor colorWithRed:0.175f green:0.458f blue:0.831f alpha:1.0f];
    [[UINavigationBar appearance] setBarTintColor:navColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    // make the status bar white
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    return YES;
}


@end
