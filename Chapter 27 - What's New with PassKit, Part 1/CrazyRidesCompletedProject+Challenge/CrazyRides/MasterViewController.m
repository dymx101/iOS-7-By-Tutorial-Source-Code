//
//  MasterViewController.m
//  CrazyRides
//
//  Created by Marin Todorov on 6/22/13.
//  Terms apply, source code provided with "iOS7 by Tutorials"
//

#import "MasterViewController.h"
#import "BookSeatViewController.h"

#import <PassKit/PassKit.h>

@interface MasterViewController () <PKAddPassesViewControllerDelegate>
{
    
}
@end

@implementation MasterViewController
{
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title"]];
    
    //scheck for Passbook availability
    if (![PKPassLibrary isPassLibraryAvailable]) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"PassKit not available"
                                   delegate:nil
                          cancelButtonTitle:@"Pitty"
                          otherButtonTitles: nil] show];
        return;
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

-(IBAction)actionBuy3MonthPass:(id)sender
{
    //"buy" the Black Friday pass
    [self showPassWithName:@"bf3monthspass"];
}

-(IBAction)actionBuyCottonCandy:(id)sender
{
    //"buy" the Cotton Candy coupon
    [self showPassWithName:@"cottoncandy2for1"];
}

-(IBAction)actionPassBundle:(id)sender
{
    //"buy" the passes bundle
}

#pragma mark - pass helper methods from "iOS6 by Tutorials"
-(void)showPassWithName:(NSString*)name
{
    //show the given pass in the add pass controller
    PKPass* pass = [self passWithName:name];
    
    PKAddPassesViewController *addController = [[PKAddPassesViewController alloc] initWithPass:pass];
    [self presentViewController:addController
                       animated:YES
                     completion:nil];
}

-(PKPass*)passWithName:(NSString*)name
{
    //load a pass from the app bundle
    NSData *passData = [NSData dataWithContentsOfFile:
                        [[NSBundle mainBundle] pathForResource:name ofType:@"pkpass"]
                        ];
    
    return [[PKPass alloc] initWithData:passData error:nil];
}

@end
