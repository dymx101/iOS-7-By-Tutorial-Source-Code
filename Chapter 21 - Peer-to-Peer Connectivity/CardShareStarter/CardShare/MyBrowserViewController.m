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
<UIToolbarDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *nearbyPeers;
@property (strong, nonatomic) NSMutableArray *acceptedPeers;
@property (strong, nonatomic) NSMutableArray *declinedPeers;

@end

@implementation MyBrowserViewController

#pragma mark Initialization methods
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
    
    self.nearbyPeers = [@[] mutableCopy];
    self.acceptedPeers = [@[] mutableCopy];
    self.declinedPeers = [@[] mutableCopy];
    
    [self showDoneButton:NO];
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

#pragma mark - Action methods

- (IBAction)cancelButtonPressed:(id)sender {
    // Send the delegate a message that the controller was canceled.
    if ([self.delegate respondsToSelector:@selector(myBrowserViewControllerWasCancelled:)]) {
        [self.delegate myBrowserViewControllerWasCancelled:self];
    }
}

- (IBAction)doneButtonPressed:(id)sender {
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
    
    return cell;
}

@end
