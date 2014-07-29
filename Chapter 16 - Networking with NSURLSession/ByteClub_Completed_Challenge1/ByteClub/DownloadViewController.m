//
//  DownloadViewController.m
//  ByteClub
//
//  Created by Charlie Fulton on 9/2/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "DownloadViewController.h"
#import "Dropbox.h"

@interface DownloadViewController ()<NSURLSessionDownloadDelegate>

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *panoPhotoView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;


@end

@implementation DownloadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
  
  _progressView.progress = 0;
  _fileNameLabel.text = [[_path componentsSeparatedByString:@"/"] lastObject];
 
  NSLog(@"downloading path %@",_path);
  
  
  // create session, setup self as delegate for downloads
  NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
  [config setHTTPAdditionalHeaders:@{@"Authorization": [Dropbox apiAuthorizationHeader]}];
  
  _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
  
  
  
  [self downloadTaskWithDelegate];

}

#pragma mark -
#pragma NSURLSessionDownloadDelegate methods

-(void)downloadTaskWithDelegate
{
  // 1
  
  NSString *imageUrl = [NSString stringWithFormat:@"https://api-content.dropbox.com/1/files/dropbox%@",_path];
  
  
  // 1
  NSURLSessionDownloadTask *getImageTask =
  [_session downloadTaskWithURL:[NSURL URLWithString:imageUrl]];
  
  
  [getImageTask resume];
}

#pragma mark -
#pragma NSURLSessionDownloadDelegate methods

-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask
     didWriteData:(int64_t)bytesWritten
totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
  NSLog(@"%f / %f", (double)totalBytesWritten,(double)totalBytesExpectedToWrite);
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [_progressView setProgress:
     (double)totalBytesWritten /
     (double)totalBytesExpectedToWrite animated:YES];
  });
  
  
}


-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
  // 1
  UIImage *downloadedImage =
  [UIImage imageWithData:
   [NSData dataWithContentsOfURL:location]];
  
  

  UIImageWriteToSavedPhotosAlbum(downloadedImage, nil, nil, nil);

  
  // 2
  dispatch_async(dispatch_get_main_queue(), ^{
    NSLog(@"updating UIImageView");
    // do stuff with image
    _panoPhotoView.image = downloadedImage;
  });
}

-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask
didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
  
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
