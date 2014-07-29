//
//  NewPushupViewController.h
//  Pushitup
//
//  Created by Cesare Rocchi on 7/9/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewPushupViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *pushupTextField;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;


- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end

extern NSString * const kAddNewPushup;