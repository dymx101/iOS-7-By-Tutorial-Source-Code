//
//  VideoListViewController.m
//  Pushitup
//
//  Created by Cesare Rocchi on 7/9/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import "VideoListViewController.h"
#import "Video.h"

@interface VideoListViewController ()

@property (nonatomic, strong) NSMutableArray *videos;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayerController;

@end

@implementation VideoListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.videos = [NSMutableArray array];

    Video *video1 = [[Video alloc] init];
    video1.videoTitle = @"Motivation";
    video1.videoURL = [NSURL URLWithString:@"http://www.studiomagnolia.it/video1.mp4"];
    [self.videos addObject:video1];

    Video *video2 = [[Video alloc] init];
    video2.videoTitle = @"Look ma, one hand!";
    video2.videoURL = [NSURL URLWithString:@"http://www.studiomagnolia.it/video2.mp4"];
    [self.videos addObject:video2];
    
    self.detailViewController = (VideoViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.videos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    Video *video = self.videos[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = video.videoTitle;
    cell.detailTextLabel.text = @"";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Video *video = self.videos[indexPath.row];
    
    self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:video.videoURL];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlaybackChanged:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    
    [self.moviePlayerController setMovieSourceType:MPMovieSourceTypeFile];
    self.moviePlayerController.shouldAutoplay = NO;
    NSLog(@"playing %@", video.videoURL);
    [self.moviePlayerController.view setFrame:self.view.bounds];
    [self.view addSubview:self.moviePlayerController.view];
    self.moviePlayerController.fullscreen = YES;

    [self.moviePlayerController play];
    
}


- (void) moviePlaybackChanged: (NSNotification *) notification {
    
    NSLog(@"moviePlaybackChanged");
    
    NSLog(@"state is %d", self.moviePlayerController.playbackState);
    
    if (self.moviePlayerController.playbackState == MPMoviePlaybackStatePaused) // true when pressing done. Filed a radar
        [self.moviePlayerController.view removeFromSuperview];
    
}

- (void) moviePlayBackDidFinish: (NSNotification *) notification {
    
    NSLog(@"finish");
    [self.moviePlayerController.view removeFromSuperview];
    
}

@end
