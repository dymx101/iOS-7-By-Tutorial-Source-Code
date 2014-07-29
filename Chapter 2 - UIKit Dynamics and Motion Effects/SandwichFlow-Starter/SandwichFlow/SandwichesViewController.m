//
//  SanwichesViewController.m
//  SandwichFlow
//
//  Created by Colin Eberhardt on 02/08/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "SandwichesViewController.h"
#import "SandwichViewController.h"
#import "AppDelegate.h"

@interface SandwichesViewController ()

@end

@implementation SandwichesViewController

- (NSArray*) sandwiches
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.sandwiches;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 250)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UIImageView* header = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Sarnie"]];
    header.center = CGPointMake(220, 190);
    [headerView addSubview:header];
    
    self.tableView.tableHeaderView = headerView;
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background-LowerLayer"]]];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SandwichViewController* sandwichVC = (SandwichViewController*)segue.destinationViewController;
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    sandwichVC.sandwich = [self sandwiches][path.row];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self sandwiches].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
    
    NSDictionary* sandwich = (NSDictionary*)[self sandwiches][indexPath.row];
    cell.textLabel.text = sandwich[@"title"];
    
    return cell;
}

@end
