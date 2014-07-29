//
//  Download.h
//  ProgressChallenge
//
//  Created by Matt Galloway on 25/08/2013.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Downloader;

@interface Download : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSURL *url;

@property (nonatomic, copy) NSString *downloadedDirectoryPath;

@end
