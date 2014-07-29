//
//  Downloader.h
//  ProgressChallenge
//
//  Created by Matt Galloway on 25/08/2013.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DownloaderHandler)(NSData *data, NSError *error);

@interface Downloader : NSObject

- (instancetype)initWithURL:(NSURL*)url;

- (void)startWithHandler:(DownloaderHandler)handler;

@end
