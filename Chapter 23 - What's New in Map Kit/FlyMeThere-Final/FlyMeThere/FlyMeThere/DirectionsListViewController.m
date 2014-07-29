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
    NSMutableDictionary *_snapshots;
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
    _snapshots = [NSMutableDictionary new];
}


#pragma mark -

- (void)loadSnapshotForCellAtIndexPath:(NSIndexPath*)indexPath {
    // 1
    MKRouteStep *step = nil;
    switch (indexPath.section) {
        case 0: {
            step = _route.toSourceAirportRoute.steps[indexPath.row];
        }
            break;
        case 2: {
            step = _route.fromDestinationAirportRoute.steps[indexPath.row];
        }
            break;
    }
    
    // 2
    if (step) {
        // 3
        MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
        options.scale = [[UIScreen mainScreen] scale];
        options.region = CoordinateRegionBoundingMapPoints(step.polyline.points, step.polyline.pointCount);
        options.size = CGSizeMake(44.0f, 44.0f);
        
        // 4
        MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
        [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
            if (!error) {
                // 5
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 6
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    
                    // 7
                    if (cell) {
                        cell.imageView.image = snapshot.image;
                        [cell setNeedsLayout];
                    }
                    
                    // 8
                    _snapshots[indexPath] = snapshot.image;
                });
            }
        }];
    }
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
        
        UIImage *cachedSnapshot = _snapshots[indexPath];
        if (cachedSnapshot) {
            cell.imageView.image = cachedSnapshot;
        } else {
            [self loadSnapshotForCellAtIndexPath:indexPath];
        }
    }
    
    return cell;
}

@end
