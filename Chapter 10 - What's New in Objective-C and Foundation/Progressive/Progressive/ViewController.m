//
//  ViewController.m
//  Progressive
//
//  Created by Matt Galloway on 07/08/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@end

@implementation ViewController {
    NSProgress *_progress;
    dispatch_queue_t _queue;
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    _queue = dispatch_queue_create("com.razeware.Progressive", DISPATCH_QUEUE_CONCURRENT);
}

- (void)updateProgressLabel {
    _progressLabel.text = [NSString stringWithFormat:@"%.2f%%", _progress.fractionCompleted * 100.0];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == _progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateProgressLabel];
        });
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


#pragma mark - Actions

- (IBAction)startTaskTapped:(id)sender {
    if (_progress) {
        return;
    }
    
    _progress = [NSProgress progressWithTotalUnitCount:9];
    [_progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
    
    dispatch_async(_queue, ^{
        [_progress becomeCurrentWithPendingUnitCount:3];
        [self doA];
        [_progress resignCurrent];
        _progress.completedUnitCount = 3;
        
        [_progress becomeCurrentWithPendingUnitCount:6];
        [self doB];
        [_progress resignCurrent];
        _progress.completedUnitCount = 3 + 6;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateProgressLabel];
            [_progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
            _progress = nil;
        });
    });
}


#pragma mark -

- (void)doA {
    NSLog(@"doA");
    NSInteger mSecToSleep = arc4random_uniform(500);
    
    NSProgress *progress = [NSProgress progressWithTotalUnitCount:mSecToSleep];
    for (NSInteger i = 0; i < mSecToSleep; i++) {
        usleep(1000);
        progress.completedUnitCount = i+1;
    }
}

- (void)doB {
    NSLog(@"doB");
    NSInteger mSecToSleep = arc4random_uniform(1000);
    
    NSProgress *progress = [NSProgress progressWithTotalUnitCount:mSecToSleep];
    for (NSInteger i = 0; i < mSecToSleep; i++) {
        usleep(1000);
        progress.completedUnitCount = i+1;
    }
}

@end
