//
//  ViewDownloadViewController.m
//  ProgressChallenge
//
//  Created by Matt Galloway on 25/08/2013.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "ViewDownloadViewController.h"

#import "Download.h"

@interface ViewDownloadViewController ()

@property (nonatomic, strong) Download *download;
@property (nonatomic, strong) NSArray *files;

@end

@implementation ViewDownloadViewController

- (instancetype)initWithDownload:(Download *)download {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _download = download;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _download.title;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    NSMutableArray *files = [NSMutableArray new];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:_download.downloadedDirectoryPath];
    for (NSString *file in enumerator) {
        [files addObject:file];
    }
    
    self.files = [files copy];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = _files[indexPath.row];
    return cell;
}

@end
