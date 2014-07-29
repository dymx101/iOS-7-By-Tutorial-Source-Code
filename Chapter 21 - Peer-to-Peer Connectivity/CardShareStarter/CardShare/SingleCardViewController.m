//
//  MyCardViewController.m
//  GreatExchange
//
//  Created by Christine Abernathy on 7/9/13.
//  Copyright (c) 2013 Elidora LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Card.h"
#import "SingleCardViewController.h"

@interface SingleCardViewController ()
<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (weak, nonatomic) IBOutlet UIButton *addToCardsButton;

@end

@implementation SingleCardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _card = nil;
        _enableAddToCards = NO;
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (nil == self.card) {
        AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [self fetchCardInfo:delegate.myCard];
    } else {
        [self fetchCardInfo:self.card];
        self.navigationItem.rightBarButtonItem = nil;
    }
    if (self.enableAddToCards) {
        self.addToCardsButton.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper methods
- (void) fetchCardInfo:(Card *)card
{
    // Get the card values
    if (nil != card) {
        self.imageView.image = card.image;
        self.fullNameLabel.text = [NSString stringWithFormat:@"%@ %@", card.firstName, card.lastName];
        self.companyLabel.text = card.company;
        self.emailLabel.text = card.email;
        self.phoneLabel.text = card.phone;
        self.websiteLabel.text = card.website;
        
        // Un-gray out the default fonts
        self.fullNameLabel.textColor = [UIColor blackColor];
    }
}

#pragma mark - Action methods
- (IBAction)addToCardsPressed:(id)sender {
    if (nil != self.card) {
        AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [delegate addToOtherCardsList:self.card];
        
        // Remove the card from the exchange card list
        [delegate removeCardFromExchangeList:self.card];
        
        // Display a confirmation message to the user
        [[[UIAlertView alloc] initWithTitle:@"Success"
                                    message:@"Added the selected business card to your list"
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil]
         show];
    }
}

#pragma mark - AlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
