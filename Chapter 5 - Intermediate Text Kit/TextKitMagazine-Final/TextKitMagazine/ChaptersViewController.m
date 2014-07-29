//
//  MasterViewController.m
//  TextKitMagazine
//
//  Created by Colin Eberhardt on 02/07/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "ChaptersViewController.h"
#import "AppDelegate.h"
#import "BookViewController.h"
#import "Chapter.h"

@interface ChaptersViewController ()

@end

@implementation ChaptersViewController

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = YES;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.bookViewController = (BookViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (NSArray*)chapters {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.chapters;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self chapters].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Chapter* chapter = [self chapters][indexPath.row];
    cell.textLabel.text = chapter.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Chapter* chapter = [self chapters][indexPath.row];
    [self.bookViewController navigateToCharacterLocation:chapter.location];
}

@end
