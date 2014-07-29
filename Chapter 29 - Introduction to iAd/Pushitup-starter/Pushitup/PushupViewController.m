//
//  PushupViewController.m
//  Pushitup
//
//  Created by Cesare Rocchi on 7/9/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import "PushupViewController.h"

@interface PushupViewController ()

- (void) configureView;

@end

@implementation PushupViewController

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

-(void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
}

- (void) setPushUp:(Pushup *)pushUp {

    if (_pushUp != pushUp) {
        
        _pushUp = pushUp;
        
    }
    
}

-(void)setPreviousPushUp:(Pushup *)previousPushUp {

    if (_previousPushUp != previousPushUp) {
    
        _previousPushUp = previousPushUp;
        [self configureView];
        
    }
    
}

- (void) configureView {
    
    if (self.previousPushUp == nil) {
    
        self.arrowImageView.hidden = YES;
        self.explanationLabel.hidden = YES;
        
    } else {

        self.explanationLabel.hidden = NO;
        NSInteger difference = self.pushUp.numberOfPushups - self.previousPushUp.numberOfPushups;

        if (difference > 0) {
        
            
            self.explanationLabel.text = [NSString stringWithFormat:@"UP %i FROM LAST SESSION", difference];
            self.arrowImageView.image = [UIImage imageNamed:@"bigarrowup.png"];
            
        } else {
        
            self.explanationLabel.text = [NSString stringWithFormat:@"DOWN %i FROM LAST SESSION", difference*-1];
            self.arrowImageView.image = [UIImage imageNamed:@"bigarrowdown.png"];
            
        }
        
    }
    
    self.pushupLabel.text = [NSString stringWithFormat:@"%i", self.pushUp.numberOfPushups];
    self.dateLabel.text = [self.pushUp stringDate];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
