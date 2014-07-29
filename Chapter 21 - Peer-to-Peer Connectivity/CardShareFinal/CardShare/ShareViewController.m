//
//  ViewController.m
//  GreatExchange
//
//  Created by Christine Abernathy on 6/27/13.
//  Copyright (c) 2013 Elidora LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "ShareViewController.h"
#import "MyBrowserViewController.h"
#import "Card.h"
#import "SingleCardViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ShareViewController ()
<MCBrowserViewControllerDelegate,
MyBrowserViewControllerDelegate,
UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *emptyAddButton;
@property (strong, nonatomic) Card *selectedCard;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *exchangeNavBarButton;
@property (weak, nonatomic) IBOutlet UILabel *emptyInstructionsLabel;

@end

@implementation ShareViewController

#pragma mark - View lifecycle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Register for notifications on data received changes
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(dataReceived:)
     name:DataReceivedNotification
     object:nil];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self dataReceived:nil];
}

#pragma mark - Action methods
- (IBAction)addCardPressed:(id)sender {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    // Check if the user has set up their business card
    if (nil == delegate.myCard) {
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:@"Please set up your business card first"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil]
         show];
    } else {
        if ([[delegate.session connectedPeers] count] == 0) {
            // Set up a browser
            if (kProgrammaticDiscovery) {
                // Call the custom view controller that sets up
                // a browser programmatically
                [self performSegueWithIdentifier:@"SegueToMyBrowser" sender:self];
            } else {
                MCBrowserViewController *browserViewController = [[MCBrowserViewController alloc]
                                               initWithServiceType:kServiceType
                                               session:delegate.session];
                browserViewController.view.tintColor = [UIColor whiteColor];
                browserViewController.delegate = self;
                [self presentViewController:browserViewController animated:YES completion:nil];
            }
        } else {
            // Connected, start exchange process
            [self sendCard];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToMyBrowser"]) {
        AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        MyBrowserViewController *browserViewController = (MyBrowserViewController *)segue.destinationViewController;
        [browserViewController setupWithServiceType:kServiceType session:delegate.session peer:delegate.peerId];
        browserViewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"SegueToCardDetail"]) {
        SingleCardViewController *singleCardViewController = (SingleCardViewController *)segue.destinationViewController;
        singleCardViewController.card = self.selectedCard;
        singleCardViewController.enableAddToCards = YES;
    }
}

#pragma mark MCBrowserViewControllerDelegate delegate methods
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:^{
        [self sendCard];
    }];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark MyBrowserViewControllerDelegate delegate methods
- (void)myBrowserViewControllerDidFinish:(MyBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:^{
        [self sendCard];
    }];
}

- (void)myBrowserViewControllerWasCancelled:(MyBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView delegate and datasource methods
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    return [delegate.cards count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    Card *card = delegate.cards[indexPath.row];
    
    static NSString *CellIdentifier = @"CardsCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", card.firstName, card.lastName];
    cell.detailTextLabel.text = card.company;
    cell.imageView.image = card.image;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    self.selectedCard = delegate.cards[indexPath.row];
    [self performSegueWithIdentifier:@"SegueToCardDetail" sender:self];
}

#pragma mark - Helper methods
- (void) showHideNoDataView
{
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([delegate.cards count] == 0) {
        self.emptyAddButton.hidden = NO;
        self.emptyInstructionsLabel.hidden = NO;
        self.tableView.hidden = YES;
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.emptyAddButton.hidden = YES;
        self.emptyInstructionsLabel.hidden = YES;
        self.tableView.hidden = NO;
        self.navigationItem.rightBarButtonItem = self.exchangeNavBarButton;
    }
}

- (void) dataReceived:(NSNotification *)notification
{
    [self showHideNoDataView];
    [self.tableView reloadData];
}

- (void) showMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@""
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}

- (void) sendCard {
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [delegate sendCardToPeer];
    [self showMessage:@"Card sent to nearby device"];
}

@end
