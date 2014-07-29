//
//  RestaurantDetailViewController.m
//  Aroma
//
//  Created by Chris Wagner on 8/3/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "RestaurantDetailViewController.h"
#import "Restaurant.h"
#import "MultipeerConnectivityService.h"
#import "ReserveTableViewController.h"
#import "AppDelegate.h"

@interface RestaurantDetailViewController () <MultipeerConnecivityServiceDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *motdLabel;
@property (weak, nonatomic) IBOutlet UITextView *motdTextView;
@property (weak, nonatomic) IBOutlet UIButton *reserveATableButton;

@end

@implementation RestaurantDetailViewController {
    BOOL _connectedToHostStand;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [_imageView setImage:_restaurant.image];
    _motdLabel.text = _restaurant.motdHeader;
    _motdTextView.text = _restaurant.motdBody;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)reserveATable:(id)sender {
    [MultipeerConnectivityService sharedService].delegate = self;
    if (self.containingViewController) {
        [[MultipeerConnectivityService sharedService] presentBrowserFromViewController:self.containingViewController peerName:@"Guest"];
    } else {
        [[MultipeerConnectivityService sharedService] presentBrowserFromViewController:self peerName:@"Guest"];
    }
}

#pragma mark - MultipeerConnecivityServiceDelegate methods

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [browserViewController dismissViewControllerAnimated:YES completion:^{
        ReserveTableViewController *reserveTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReserveTableViewController"];
        [reserveTableViewController setCompletion:^(NSString *name, NSNumber *partySize) {
            NSError *sendError = nil;
            NSDictionary *guestInfo = @{@"name": name,
                                        @"partySize": partySize};
            [[MultipeerConnectivityService sharedService] sendMessage:[NSKeyedArchiver archivedDataWithRootObject:guestInfo] error:&sendError];
        }];
        if (self.containingViewController) {
            [self.containingViewController presentViewController:reserveTableViewController animated:YES completion:nil];
        } else {
            [self presentViewController:reserveTableViewController animated:YES completion:nil];
        }
        
    }];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
