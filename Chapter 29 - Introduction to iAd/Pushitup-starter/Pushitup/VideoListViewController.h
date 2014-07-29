//
//  VideoListViewController.h
//  Pushitup
//
//  Created by Cesare Rocchi on 7/9/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VideoViewController.h"

@interface VideoListViewController : UITableViewController

@property (strong, nonatomic) VideoViewController *detailViewController;

@end
