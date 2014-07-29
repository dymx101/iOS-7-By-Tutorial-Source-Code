//
//  MasterViewController.m
//  CrazyRides
//
//  Created by Marin Todorov on 6/22/13.
//  Terms apply, source code provided with "iOS7 by Tutorials"
//

#import "MasterViewController.h"
#import "BookSeatViewController.h"

@import PassKit;

@interface MasterViewController () <PKAddPassesViewControllerDelegate, UIAlertViewDelegate>
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
    PKPass* bfPass = [self passWithName:@"bf3monthspass"];
    NSString* customerName = bfPass.userInfo[@"customerName"];
    
    [[[UIAlertView alloc] initWithTitle:@"Confirm pass"
                                message:[NSString stringWithFormat:@"Are you double sure, %@?", customerName]
                               delegate:self
                      cancelButtonTitle:@"No"
                      otherButtonTitles:@"Yes", nil] show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        [self showPassWithName:@"bf3monthspass"];
    }
}

-(IBAction)actionBuyCottonCandy:(id)sender
{
    //"buy" the Cotton Candy coupon
    [self showPassWithName:@"cottoncandy2for1"];
}

-(IBAction)actionPassBundle:(id)sender
{
    //"buy" the passes bundle
    //fetch the user pass library
    PKPassLibrary* passLibrary = [[PKPassLibrary alloc] init];
    
    //add 3 passes at once
    [passLibrary addPasses:[self passBundle]
     withCompletionHandler:^(PKPassLibraryAddPassesStatus status) {
         //callback block
         
         //call on the main thread
         [self performSelectorOnMainThread:
          @selector(bundleAddDidCompleteWithCode:)
                                withObject:@(status)
                             waitUntilDone:NO];

     }];
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

-(NSArray*)passBundle
{
    //build an array of the 3 passes
    NSMutableArray* passBundle =
    [NSMutableArray arrayWithCapacity:3];
    
    [passBundle addObject: [self passWithName:@"bf3monthspass"]];
    [passBundle addObject: [self passWithName:@"ww3monthspass"]];
    [passBundle addObject: [self passWithName:@"cottoncandy2for1"]];
    
    return [passBundle copy];
}

-(void)showPassBundle
{
    //show the 3 passes in the add pass controller
    NSArray* passes = [self passBundle];
    
    PKAddPassesViewController* addPasses =
    [[PKAddPassesViewController alloc] initWithPasses: passes];
    
    [self presentViewController:addPasses
                       animated:YES
                     completion:nil];
}

-(void)bundleAddDidCompleteWithCode:(NSNumber*)status
{
    //action completed
    if ([status intValue]==PKPassLibraryShouldReviewPasses) {
        
        //the user wants to review the pass bundle
        [self showPassBundle];
        
    } else if ([status intValue]==PKPassLibraryDidAddPasses) {
        //success message
        [[[UIAlertView alloc] initWithTitle:@"Thanks!"
                                    message:@"Thanks for purchasing the 2 passes bundle, we've thrown in also a cotton candy coupon. Enjoy!"
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles: nil] show];
    }
}

@end
