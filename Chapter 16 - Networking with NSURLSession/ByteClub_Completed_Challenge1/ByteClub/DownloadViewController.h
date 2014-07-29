//
//  DownloadViewController.h
//  ByteClub
//
//  Created by Charlie Fulton on 9/2/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadViewController : UIViewController

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSURLSession *session;


@end
