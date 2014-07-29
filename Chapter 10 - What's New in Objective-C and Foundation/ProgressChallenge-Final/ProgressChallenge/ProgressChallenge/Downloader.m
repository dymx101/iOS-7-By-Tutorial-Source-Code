//
//  Downloader.m
//  ProgressChallenge
//
//  Created by Matt Galloway on 25/08/2013.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Downloader.h"

@interface Downloader () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, copy) DownloaderHandler handler;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSProgress *progress;

@end

@implementation Downloader

#pragma mark -

- (instancetype)initWithURL:(NSURL*)url {
    if ((self = [super init])) {
        _url = url;
    }
    return self;
}


#pragma mark -

- (void)startWithHandler:(DownloaderHandler)handler {
    self.handler = handler;
    
    self.progress = [[NSProgress alloc] initWithParent:[NSProgress currentProgress] userInfo:nil];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:_url];
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [_connection start];
}

- (void)_finishWithError:(NSError*)error {
    _progress.completedUnitCount = _progress.totalUnitCount;
    
    if (_handler) {
        _handler(_data, error);
        self.handler = nil;
    }
    
    self.data = nil;
    self.connection = nil;
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.data = [NSMutableData new];
    _progress.totalUnitCount = response.expectedContentLength;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
    _progress.completedUnitCount = MIN(_data.length, _progress.totalUnitCount);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self _finishWithError:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.data = nil;
    [self _finishWithError:error];
}

@end
