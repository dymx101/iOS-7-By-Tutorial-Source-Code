//
//  BookSeatViewController.m
//  CrazyRides
//
//  Created by Marin Todorov on 6/22/13.
//  Terms apply, source code provided with "iOS7 by Tutorials"
//

#import "BookSeatViewController.h"
#import "AppDelegate.h"

//tags for the buttons
#define kBlackFridayButtonTag 1
#define kWildRollerButtonTag  2

@interface BookSeatViewController () <UIAlertViewDelegate>
@end

@implementation BookSeatViewController

-(void)viewDidLoad
{
    self.navigationItem.title = @"Reserve a seat";
}

-(void)viewDidAppear:(BOOL)animated
{
    //the view did appear on the screen
    
}

-(IBAction)actionReserveSeat:(UIButton*)sender
{
    //detect which buttion was tapped, show the booking dialogue
    NSString *rideName = (sender.tag==kBlackFridayButtonTag)?@"Black Friday":@"Wild Roller";
    [self bookRideWithName: rideName];
}

-(void)bookRideWithName:(NSString*)rideName
{
    //show the book seat dialogue
    [[[UIAlertView alloc] initWithTitle:rideName
                                message:[NSString stringWithFormat:@"Are you sure you want to reserve a seat on the %@ ride now?", rideName]
                               delegate:self
                      cancelButtonTitle:@"No"
                      otherButtonTitles:@"Absolutely", nil] show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //if user pressed OK, show a success message
    if (buttonIndex==1) {
        [[[UIAlertView alloc] initWithTitle:@"Success"
                                    message:@"Your seat is reserved for the next 20 minutes"
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles: nil] show];
    }
}

@end
