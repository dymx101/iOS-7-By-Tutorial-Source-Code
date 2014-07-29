//
//  GameViewController.h
//  ReversiGame
//
//  Created by Colin Eberhardt on 07/12/2012.
//  Copyright (c) 2012 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ReversiBoardDelegate.h"

@interface GameViewController : UIViewController <ReversiBoardDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *gameOverImage;

@property (weak, nonatomic) IBOutlet UILabel *blackScore;
@property (weak, nonatomic) IBOutlet UILabel *whiteScore;

@property (weak, nonatomic) IBOutlet UIImageView *blackActive;
@property (weak, nonatomic) IBOutlet UIImageView *whiteActive;

@property (weak, nonatomic) IBOutlet UIView *startButtonsView;

- (IBAction)start2PlayerGame:(id)sender;
- (IBAction)startVsComputerGame:(id)sender;

@end
