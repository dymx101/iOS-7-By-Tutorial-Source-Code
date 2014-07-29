//
//  DownloadCell.m
//  ProgressChallenge
//
//  Created by Matt Galloway on 25/08/2013.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "DownloadCell.h"

#import "Download.h"
#import "Downloader.h"

@interface DownloadCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *progressBar;

@property (nonatomic, strong) NSProgress *progress;

@end

@implementation DownloadCell

#pragma mark -

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    }
    return self;
}

- (void)dealloc {
    if (_progress) {
        [_progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
    }
}


#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == _progress) {
        [self _updateProgress];
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)_updateProgress {
    NSLog(@"progress = %.5f", _progress.fractionCompleted);
    _progressBar.progress = _progress.fractionCompleted;
}


#pragma mark -

- (void)setupWithDownload:(Download*)download {
    self.titleLabel.text = download.title;
}

- (void)setProgress:(NSProgress*)progress {
    if (_progress) {
        [_progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
    }
    
    _progress = progress;
    
    if (progress) {
        [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    [self _updateProgress];
}

@end
