//
//  SAAppDelegate.m
//  DropMe
//
//  Created by Soheil Azarpour on 6/25/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Customize overall tint color appearance.
    self.window.tintColor = [UIColor whiteColor];
    
    // Customize overall navigation bar appearance.
    UIImage *blueColorPattern = [[UIImage imageNamed:@"blueColorPattern"] resizableImageWithCapInsets:UIEdgeInsetsZero];
    [[UINavigationBar appearance] setBackgroundImage:blueColorPattern forBarMetrics:UIBarMetricsDefault];
    
    // Customize overall tab bar apperance.
    UIColor *backgroundBlueTint = RGBColor(35.0, 141.0, 207.0);
    [[UITabBar appearance] setBarTintColor:backgroundBlueTint];
    
    UIColor *normalBlueTine = RGBColor(135.0, 193.0, 230.0);
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : normalBlueTine } forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] } forState:UIControlStateSelected];
    
    // If this is the very first time ever the app is being run,
    // copy sample files to user documents directory, so that
    // user has something to start with.
    if ([self isFirstRun])
    {
        NSURL *rainFile = [[NSBundle mainBundle] URLForResource:@"Rain" withExtension:@"dm"];
        NSURL *rainFileCopy = [UserDocumentsDirectory() URLByAppendingPathComponent:@"Rain.dm"];
        
        NSURL *waterFile = [[NSBundle mainBundle] URLForResource:@"Water" withExtension:@"dm"];
        NSURL *waterFileCopy = [UserDocumentsDirectory() URLByAppendingPathComponent:@"Water.dm"];
        
        [[NSFileManager defaultManager] copyItemAtURL:rainFile toURL:rainFileCopy error:nil];
        [[NSFileManager defaultManager] copyItemAtURL:waterFile toURL:waterFileCopy error:nil];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // Append the current date-time to the beginning of the file to
    // avoid conflicts.
    NSString *fileName = [NSString stringWithFormat:@"%@-%@", FormattedStringWithDate([NSDate date]), url.lastPathComponent];
    NSURL *destinationURL = [UserDocumentsDirectory() URLByAppendingPathComponent:fileName];
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] moveItemAtURL:url toURL:destinationURL error:&error];
    if (!success)
    {
        NSLog(@"%@", error.localizedDescription);
    }
    else
    {
        // If successful, land user in Documents view controller.
        UITabBarController *controller = (UITabBarController *)self.window.rootViewController;
        [controller setSelectedIndex:4];
        
        // Send a notification so that interested classes can update.
        [[NSNotificationCenter defaultCenter] postNotificationName:DocumentsDirectoryContentDidChangeNotification object:self];
    }
    
    return YES;
}

#pragma mark
#pragma mark - Helper methods

/*
 * Returns YES if this is the very first time the app
 * is being run on a device; otherwise it returns NO.
 */
- (BOOL)isFirstRun
{
    NSString *initializedKey = @"com.razeware.dropme.initializedKey";
    BOOL isInitialized = [[NSUserDefaults standardUserDefaults] boolForKey:initializedKey];
    
    if (!isInitialized)
    {
        // Flag it so next time we know this is not
        // the first time ever the app is being run.
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:initializedKey];
    }
    
    // For greater legibility!
    BOOL isFirstRun = !isInitialized;
    
    return isFirstRun;
}

@end
