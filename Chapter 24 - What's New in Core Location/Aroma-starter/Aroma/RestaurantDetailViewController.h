//
//  RestaurantDetailViewController.h
//  Aroma
//
//  Created by Chris Wagner on 8/3/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Restaurant;

@interface RestaurantDetailViewController : UIViewController

@property (strong, nonatomic) Restaurant *restaurant;
@property (weak, nonatomic) UIViewController *containingViewController;

@end
