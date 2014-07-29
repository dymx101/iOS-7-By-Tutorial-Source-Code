//
//  ViewDownloadViewController.h
//  ProgressChallenge
//
//  Created by Matt Galloway on 25/08/2013.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Download;

@interface ViewDownloadViewController : UITableViewController

- (instancetype)initWithDownload:(Download*)download;

@end
