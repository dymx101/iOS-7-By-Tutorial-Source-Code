//
//  MyBrowserViewController.m
//  GreatExchange
//
//  Created by Christine Abernathy on 7/1/13.
//  Copyright (c) 2013 Elidora LLC. All rights reserved.
//

#import "MyBrowserViewController.h"
#import "AppDelegate.h"
#import "MyBrowserTableViewCell.h"

@interface MyBrowserViewController ()
<UIToolbarDelegate,
MCNearbyServiceBrowserDelegate>

@property (strong, nonatomic) MCNearbyServiceBrowser *browser;
@property (strong, nonatomic) NSString *serviceType;
@property (strong, nonatomic) MCPeerID *peerId;
@property (strong, nonatomic) MCSession *session;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *nearbyPeers;
@property (strong, nonatomic) NSMutableArray *acceptedPeers;
@property (strong, nonatomic) NSMutableArray *declinedPeers;

@end

@implementation MyBrowserViewController

#pragma mark Initialization methods
- (void)setupWithServiceType:(NSString *)serviceType session:(MCSession *)session peer:(MCPeerID *)peerId
{
    self.serviceType = serviceType;
    self.session = session;
    self.peerId = peerId;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        // Default maximum and minimum number of
        // peers allowed in a session
        self.maximumNumberOfPeers = 8;
        self.minimumNumberOfPeers = 2;
    }
    return self;
}

#pragma mark - View lifecycle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Set the toolbar delegate to be able
    // to position it to the top of the view.
    self.toolbar.delegate = self;
    
    // Register for notifications on data received changes
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(peerConnected:)
     name:PeerConnectionAcceptedNotification
     object:nil];
    
    self.nearbyPeers = [@[] mutableCopy];
    self.acceptedPeers = [@[] mutableCopy];
    self.declinedPeers = [@[] mutableCopy];
    
    [self showDoneButton:NO];
    
    // Set up a browser, programmatically
    self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerId
                                                    serviceType:self.serviceType];
    self.browser.delegate = self;
    // Start browsing
    [self.browser startBrowsingForPeers];
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

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIToolbarDelegate methods
- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
    
}

#pragma mark - Helper methods
- (void)showDoneButton:(BOOL)display
{
    NSMutableArray *toolbarButtons = [[self.toolbar items] mutableCopy];
    if (display) {
        // Show the done button
        if (![toolbarButtons containsObject:self.doneButton]) {
            [toolbarButtons addObject:self.doneButton];
            [self.toolbar setItems:toolbarButtons animated:NO];
        }
    } else {
        // Hide the done button
        [toolbarButtons removeObject:self.doneButton];
        [self.toolbar setItems:toolbarButtons animated:NO];
    }
}

- (void) peerConnected:(NSNotification *)notification
{
    MCPeerID *peer = (MCPeerID *)[notification userInfo][@"peer"];
    
    // Check the nearby device's decision
    BOOL nearbyDeviceDecision = [[notification userInfo][@"accept"] boolValue];
    if (nearbyDeviceDecision) {
        [self.acceptedPeers addObject:peer];
    } else {
        [self.declinedPeers addObject:peer];
    }
    
    // Update display and flow ased on the number of connected peers
    if ([self.acceptedPeers count] >= (self.maximumNumberOfPeers - 1)) {
        // Trigger Done button if number of connected peers
        // is above the maximum.
        [self doneButtonPressed:nil];
    } else {
        // Hide or show the done button depending
        // on number of connected devices
        if ([self.acceptedPeers count] < (self.minimumNumberOfPeers - 1)) {
            [self showDoneButton:NO];
        } else {
            [self showDoneButton:YES];
        }
        // Reload the data
        [self.tableView reloadData];
    }
}

#pragma mark MCNearbyServiceBrowserDelegate delegate methods
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"Error browsing: %@", error.localizedDescription);
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    // Add the peer found to the nearby list and reload the table
    [self.nearbyPeers addObject:peerID];
    [self.tableView reloadData];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    // Clear peer info
    [self.nearbyPeers removeObject:peerID];
    [self.acceptedPeers removeObject:peerID];
    [self.declinedPeers removeObject:peerID];

    // Upate the done button visibility, if the nearby
    // connected devices are below the threshold
    if ([self.acceptedPeers count] < (self.minimumNumberOfPeers - 1)) {
        [self showDoneButton:NO];
    }
    
    // Reload the data
    [self.tableView reloadData];
        
}

#pragma mark - Action methods

- (IBAction)cancelButtonPressed:(id)sender {
    // If the user clicks Cancel, cleanup. Stop browsing.
    [self.browser stopBrowsingForPeers];
    self.browser.delegate = nil;
    // Send the delegate a message that the controller was canceled.
    if ([self.delegate respondsToSelector:@selector(myBrowserViewControllerWasCancelled:)]) {
        [self.delegate myBrowserViewControllerWasCancelled:self];
    }
}

- (IBAction)doneButtonPressed:(id)sender {
    // If the user clicks Done, cleanup. Stop browsing.
    [self.browser stopBrowsingForPeers];
    self.browser.delegate = nil;
    // Send the delegate a message that the controller was done browsing.
    if ([self.delegate respondsToSelector:@selector(myBrowserViewControllerDidFinish:)]) {
        [self.delegate myBrowserViewControllerDidFinish:self];
    }
}

#pragma mark - Table view data source and delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.nearbyPeers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NearbyDevicesCell";
    MyBrowserTableViewCell *cell = (MyBrowserTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MyBrowserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
    }
    MCPeerID *cellPeerId = (MCPeerID *) self.nearbyPeers[indexPath.row];
    if ([self.acceptedPeers containsObject:cellPeerId]) {
        if ([cell.accessoryView isKindOfClass:[UIActivityIndicatorView class]]) {
            UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)cell.accessoryView;
            [activityIndicatorView stopAnimating];
        }
        UILabel *checkmarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        checkmarkLabel.text = @" √ ";
        cell.accessoryView = checkmarkLabel;
    } else if ([self.declinedPeers containsObject:cellPeerId]) {
        if ([cell.accessoryView isKindOfClass:[UIActivityIndicatorView class]]) {
            UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)cell.accessoryView;
            [activityIndicatorView stopAnimating];
        }
        UILabel *unCheckmarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        unCheckmarkLabel.text = @" X ";
        cell.accessoryView = unCheckmarkLabel;
    } else {
        // Set up an activitiy indicator
        UIActivityIndicatorView *activityIndicatorView =
        [[UIActivityIndicatorView alloc]
         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.hidesWhenStopped = YES;
        [activityIndicatorView setColor:
         [(AppDelegate *)[[UIApplication sharedApplication]
                          delegate] mainColor]];
        [activityIndicatorView startAnimating];
        // Assign the indiicator to the cell's accessory view
        cell.accessoryView = activityIndicatorView;
        
        // Send an invitation to the selected device.
        [self.browser invitePeer:cellPeerId
                       toSession:self.session
                     withContext:[@"Making contact" dataUsingEncoding:NSUTF8StringEncoding]
                         timeout:10];
    }
    cell.textLabel.text = cellPeerId.displayName;
    
    return cell;
}

@end
