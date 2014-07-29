//
//  TipViewController.m
//  Pushitup
//
//  Created by Cesare Rocchi on 7/9/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import "TipViewController.h"

@interface TipViewController ()

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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
