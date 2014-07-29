//
//  ViewController.m
//  ProgressChallenge
//
//  Created by Matt Galloway on 25/08/2013.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "ViewController.h"

#import "ViewDownloadViewController.h"
#import "DownloadCell.h"
#import "Download.h"
#import "DownloadProcessor.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation ViewController {
    NSArray *_downloads;
    NSMutableDictionary *_downloadToProcessorMap;
    NSMutableDictionary *_downloadToProgressMap;
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *downloads = [NSMutableArray new];
    
    NSArray *downloadData = [[NSArray alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Downloads" withExtension:@"plist"]];
    [downloadData enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
        Download *download = [Download new];
        download.title = data[@"title"];
        download.url = [NSURL URLWithString:data[@"url"]];
        [downloads addObject:download];
    }];
    
    _downloads = [downloads copy];
    _downloadToProcessorMap = [NSMutableDictionary new];
    _downloadToProgressMap = [NSMutableDictionary new];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _downloads.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadCell *cell = (DownloadCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Download *download = _downloads[indexPath.row];
    [cell setupWithDownload:download];
    
    NSProgress *progress = _downloadToProgressMap[[NSValue valueWithNonretainedObject:download]];
    [cell setProgress:progress];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Download *download = _downloads[indexPath.row];
    
    if (download.downloadedDirectoryPath) {
        ViewDownloadViewController *viewController = [[ViewDownloadViewController alloc] initWithDownload:download];
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        NSValue *key = [NSValue valueWithNonretainedObject:download];
        
        DownloadProcessor *processor = _downloadToProcessorMap[key];
        if (!processor) {
            processor = [[DownloadProcessor alloc] initWithDownload:download];
            _downloadToProcessorMap[key] = processor;
            
            NSProgress *progress = [NSProgress progressWithTotalUnitCount:1];
            _downloadToProgressMap[key] = progress;
            [progress becomeCurrentWithPendingUnitCount:1];
            
            [processor startWithHandler:^{
                progress.completedUnitCount = 1;
                [_downloadToProcessorMap removeObjectForKey:key];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];
            
            [progress resignCurrent];
            
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
