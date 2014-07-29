//
//  DirectionsListViewController.m
//  FlyMeThere
//
//  Created by Matt Galloway on 23/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import "DirectionsListViewController.h"

#import "Route.h"
#import "Airport.h"
#import "MapKitHelpers.h"

@import MapKit;

@interface DirectionsListViewController ()
@end

@implementation DirectionsListViewController {
}

#pragma mark -

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return _route.toSourceAirportRoute.steps.count; break;
        case 1:
            return 1; break;
        case 2:
            return _route.fromDestinationAirportRoute.steps.count; break;
    }
    return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"To Airport"; break;
        case 1:
            return @"Flight"; break;
        case 2:
            return @"From Airport"; break;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.imageView.image = nil;
    
    MKRouteStep *step = nil;
    
    switch (indexPath.section) {
        case 0: {
            step = _route.toSourceAirportRoute.steps[indexPath.row];
        }
            break;
        case 1: {
            cell.textLabel.text = [NSString stringWithFormat:@"Fly from '%@' to '%@'", _route.sourceAirport.name, _route.destinationAirport.name];
            cell.detailTextLabel.text = nil;
        }
            break;
        case 2: {
            step = _route.fromDestinationAirportRoute.steps[indexPath.row];
        }
            break;
    }
    
    if (step) {
        cell.textLabel.text = step.instructions;
        cell.detailTextLabel.text = step.notice;
        
        // TODO: Load snapshot
    }
    
    return cell;
}

@end
