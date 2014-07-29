//
//  DownloadProcessor.m
//  ProgressChallenge
//
//  Created by Matt Galloway on 25/08/2013.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "DownloadProcessor.h"

#import "Download.h"
#import "Downloader.h"

#import "SSZipArchive.h"

@interface DownloadProcessor ()

@property (nonatomic, strong) Download *download;

@property (nonatomic, strong) Downloader *downloader;
@property (nonatomic, copy) DownloadProcessorHandler completion;
@property (nonatomic, strong) NSProgress *progress;

@end

@implementation DownloadProcessor

- (instancetype)initWithDownload:(Download*)download {
    if ((self = [super init])) {
        _download = download;
    }
    return self;
}

- (void)startWithHandler:(DownloadProcessorHandler)completion {
    self.completion = completion;
    
    self.progress = [NSProgress progressWithTotalUnitCount:10];
    [_progress becomeCurrentWithPendingUnitCount:8];
    
    self.downloader = [[Downloader alloc] initWithURL:_download.url];
    [_downloader startWithHandler:^(NSData *data, NSError *error) {
        _progress.completedUnitCount = 8;
        
        NSString *tempDir = NSTemporaryDirectory();
        NSUUID *uuid = [NSUUID new];
        
        NSString *unzipFolder = [tempDir stringByAppendingPathComponent:[uuid UUIDString]];
        NSString *zipFilename = [unzipFolder stringByAppendingPathExtension:@"zip"];
        
        [data writeToFile:zipFilename atomically:YES];
        
        [_progress becomeCurrentWithPendingUnitCount:2];
        
        [SSZipArchive unzipFileAtPath:zipFilename toDestination:unzipFolder];
        
        [_progress resignCurrent];
        _progress.completedUnitCount = 10;
        
        _download.downloadedDirectoryPath = unzipFolder;
        
        if (_completion) {
            _completion();
            self.completion = nil;
        }
        
        self.progress = nil;
    }];
    
    [_progress resignCurrent];
}

@end
