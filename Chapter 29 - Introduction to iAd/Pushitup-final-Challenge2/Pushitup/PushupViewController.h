//
//  PushupViewController.h
//  Pushitup
//
//  Created by Cesare Rocchi on 7/9/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pushup.h"

@interface PushupViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *pushupLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, weak) IBOutlet UILabel *explanationLabel;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, strong) Pushup *pushUp;
@property (nonatomic, strong) Pushup *previousPushUp;

@end
