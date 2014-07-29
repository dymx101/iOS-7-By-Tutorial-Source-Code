//
//  DirectionsListViewController.h
//  FlyMeThere
//
//  Created by Matt Galloway on 23/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Route;

@interface DirectionsListViewController : UITableViewController

@property (nonatomic, strong) Route *route;

@end
