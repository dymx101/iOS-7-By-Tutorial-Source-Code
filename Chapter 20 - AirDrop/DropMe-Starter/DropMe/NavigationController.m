//
//  NavigationController.m
//  DropMe
//
//  Created by Soheil Azarpour on 7/15/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "NavigationController.h"

@interface NavigationController () <UINavigationControllerDelegate>
@end

@implementation NavigationController

#pragma mark
#pragma mark - Life cycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        // Customize tab bar image and title.
        NSString *iconNameNormal = [NSString stringWithFormat:@"%@_normal", self.tabBarItem.title];
        NSString *iconNameSelected = [NSString stringWithFormat:@"%@_selected", self.tabBarItem.title];
        self.tabBarItem.image = [[UIImage imageNamed:iconNameNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [[UIImage imageNamed:iconNameSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        // Adopt the delegation.
        self.delegate = self;
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark
#pragma mark - UINavigationController delegate methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // Make the drop icon be the title view.
    UIView *titleView = viewController.navigationItem.titleView;
    if (!titleView)
    {
        viewController.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropIcon"]];
    }
}

@end
