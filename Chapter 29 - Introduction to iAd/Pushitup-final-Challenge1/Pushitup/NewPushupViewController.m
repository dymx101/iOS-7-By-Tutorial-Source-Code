//
//  NewPushupViewController.m
//  Pushitup
//
//  Created by Cesare Rocchi on 7/9/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import "NewPushupViewController.h"
#import "Pushup.h"

NSString * const kAddNewPushup = @"ADD_NEW_PUSHUP";

@interface NewPushupViewController ()

@end

@implementation NewPushupViewController

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
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)save:(id)sender {

    Pushup *p = [[Pushup alloc] initWithPushups:[self.pushupTextField.text integerValue]];
    p.date = self.datePicker.date;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddNewPushup
                                                        object:p];

    [self cancel:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
