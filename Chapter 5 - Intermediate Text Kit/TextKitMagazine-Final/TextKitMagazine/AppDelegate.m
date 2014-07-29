//
//  AppDelegate.m
//  TextKitMagazine
//
//  Created by Colin Eberhardt on 02/07/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "AppDelegate.h"
#import "MarkdownParser.h"
#import "Chapter.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"alices_adventures" ofType:@"md"];
    MarkdownParser* parser = [[MarkdownParser alloc] init];
    self.bookMarkup = [parser parseMarkdownFile:path];
    
    self.chapters = [self locateChapters:self.bookMarkup.string];


    // style the navigation bar
    UIColor* navColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    [[UINavigationBar appearance] setBarTintColor:navColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];

    // make the status bar white
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    
    // Override point for customization after application launch.
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    splitViewController.delegate = (id)navigationController.topViewController;
    return YES;
}

- (NSMutableArray*) locateChapters:(NSString*)markdown {
    NSMutableArray* chapters = [NSMutableArray new];
    [markdown enumerateSubstringsInRange:NSMakeRange(0, markdown.length)
                                    options:NSStringEnumerationByLines
                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                     if (substring.length >7 && [[substring substringToIndex:7] isEqualToString:@"CHAPTER"]) {
                                         Chapter* chapter = [Chapter new];
                                         chapter.title = substring;
                                         chapter.location = substringRange.location;
                                         [chapters addObject:chapter];
                                     }
                                 }];
    return chapters;
}
	
@end
