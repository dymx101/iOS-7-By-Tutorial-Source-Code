//
//  DownloadProcessor.h
//  ProgressChallenge
//
//  Created by Matt Galloway on 25/08/2013.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Download;

typedef void(^DownloadProcessorHandler)();

@interface DownloadProcessor : NSObject

- (instancetype)initWithDownload:(Download*)download;

- (void)startWithHandler:(DownloadProcessorHandler)completion;

@end
