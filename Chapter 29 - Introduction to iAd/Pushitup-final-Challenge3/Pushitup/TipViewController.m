//
//  TipViewController.m
//  Pushitup
//
//  Created by Cesare Rocchi on 7/9/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import "TipViewController.h"

@interface TipViewController ()

@property (nonatomic, strong) ADBannerView *bannerView;
@property (nonatomic, assign) CGRect originalTextFrame;

- (void) configureView;

@end

@implementation TipViewController

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
    self.containerView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.containerView.layer.shadowOffset = CGSizeMake(0, 2);
    self.containerView.layer.shadowRadius = 0.5f;
    self.containerView.layer.shadowOpacity = 1.0f;
    [self configureView];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        self.bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeMediumRectangle];
        self.bannerView.delegate = self;
        self.bannerView.center = self.view.center;
        self.bannerView.hidden = YES;
        [self.view addSubview:self.bannerView];
        
    }
    
    self.originalTextFrame = self.bodyTipTextView.frame;
    
}

- (void)setTip:(Tip *)tip
{
    if (_tip != tip) {
        
        _tip = tip;
        [self configureView];
        
    }
    
}

- (void) configureView {
    
    self.titleLabel.text = [self.tip.tipTItle uppercaseString];
    self.dateLabel.text = [self.tip stringDate];
    self.bodyTipTextView.text = self.tip.tipBody;
    [self.bodyTipTextView setEditable:NO];
    
}

#pragma mark - Banner delegate

- (void)bannerViewDidLoadAd:(ADBannerView *)adView {

    self.bannerView.hidden = NO;
    [self updateUI];
    
}


- (void)bannerView:(ADBannerView *)banner
didFailToReceiveAdWithError:(NSError *)error {
    
    NSLog(@"did fail load");
    self.bannerView.hidden = YES;
    [self updateUI];
    
}

- (void) updateUI {

    if (!self.bannerView.hidden) {

        self.bannerView.center = self.view.center;
        CGRect adFrame = self.bannerView.frame;
        adFrame.origin.y = self.dateLabel.frame.origin.y + self.dateLabel.frame.size.height + 70;
        self.bannerView.frame = adFrame;
        
        CGRect textFrame = self.bodyTipTextView.frame;
        textFrame.origin.y = adFrame.origin.y + adFrame.size.height;
        textFrame.size.height -= adFrame.size.height+ 20;
        self.bodyTipTextView.frame = textFrame;
        
    } else {
        
        CGRect textFrame = self.bodyTipTextView.frame;
        textFrame.origin.y = self.dateLabel.frame.origin.y + 70;
        textFrame.size.height = self.containerView.frame.size.height - textFrame.origin.y -20;
        self.bodyTipTextView.frame = textFrame;
        
        
    }
    
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    [self updateUI];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
