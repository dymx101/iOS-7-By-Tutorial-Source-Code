//
//  ViewController.m
//  FlyMeThere
//
//  Created by Matt Galloway on 22/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import "ViewController.h"

#import "DirectionsListViewController.h"

#import "Airport.h"
#import "Route.h"
#import "MapKitHelpers.h"

@import MapKit;

typedef void (^LocationCallback)(CLLocationCoordinate2D);

@interface ViewController () <MKMapViewDelegate, UISearchBarDelegate, UIActionSheetDelegate>
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@end

@implementation ViewController {
    NSArray *_airports;
    NSArray *_foundMapItems;
    LocationCallback _foundLocationCallback;
    Route *_route;
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadAirportData];
    self.navigationController.toolbarHidden = YES;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"List"]) {
        return _route != nil;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"List"]) {
        DirectionsListViewController *vc = (DirectionsListViewController*)segue.destinationViewController;
        vc.route = _route;
    }
}


#pragma mark -

- (void)loadAirportData {
    NSMutableArray *airports = [NSMutableArray new];
    
    NSURL *dataFileURL = [[NSBundle mainBundle] URLForResource:@"airports" withExtension:@"csv"];
    
    NSString *data = [NSString stringWithContentsOfURL:dataFileURL encoding:NSUTF8StringEncoding error:nil];
    
    NSCharacterSet *quotesCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:data];
    BOOL ok = YES;
    BOOL firstLine = YES;
    while (![scanner isAtEnd] && ok) {
        NSString *line = nil;
        ok = [scanner scanUpToString:@"\n" intoString:&line];
        
        if (firstLine) {
            firstLine = NO;
            continue;
        }
        
        if (line && ok) {
            NSArray *components = [line componentsSeparatedByString:@","];
            
            NSString *type = [components[2] stringByTrimmingCharactersInSet:quotesCharacterSet];
            if ([type isEqualToString:@"large_airport"]) {
                Airport *airport = [Airport new];
                airport.name = [components[3] stringByTrimmingCharactersInSet:quotesCharacterSet];
                airport.city = [components[10] stringByTrimmingCharactersInSet:quotesCharacterSet];
                airport.code = [components[13] stringByTrimmingCharactersInSet:quotesCharacterSet];
                airport.location = [[CLLocation alloc] initWithLatitude:[components[4] doubleValue]
                                                              longitude:[components[5] doubleValue]];
                
                [airports addObject:airport];
            }
        }
    }
    
    _airports = airports;
}

- (void)startSearchForText:(NSString*)searchText {
    // 1
    [_searchBar resignFirstResponder];
    _searchBar.userInteractionEnabled = NO;
    
    // 2
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    searchRequest.naturalLanguageQuery = searchText;
    
    // 3
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (response.mapItems.count > 0) {
            // 4
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a location"
                                                                     delegate:self
                                                            cancelButtonTitle:nil
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:nil];
            [response.mapItems enumerateObjectsUsingBlock:^(MKMapItem *mapItem, NSUInteger idx, BOOL *stop) {
                [actionSheet addButtonWithTitle:mapItem.placemark.title];
            }];
            
            [actionSheet addButtonWithTitle:@"Cancel"];
            actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
            
            // 5
            _foundMapItems = [response.mapItems copy];
            [actionSheet showInView:self.view];
        } else {
            // 6
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"No search results found! Try again with a different query."
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
            
            _searchBar.userInteractionEnabled = YES;
        }
    }];
}

- (MKMapItem*)mapItemForCoordinate:(CLLocationCoordinate2D)coordinate {
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    return mapItem;
}

- (void)performAfterFindingLocation:(LocationCallback)callback {
    if (self.mapView.userLocation != nil) {
        if (callback) {
            callback(self.mapView.userLocation.coordinate);
        }
    } else {
        _foundLocationCallback = [callback copy];
    }
}

- (Airport*)nearestAirportToCoordinate:(CLLocationCoordinate2D)coordinate {
    __block Airport *nearestAirport = nil;
    __block CLLocationDistance nearestDistance = DBL_MAX;
    
    CLLocation *coordinateLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    [_airports enumerateObjectsUsingBlock:^(Airport *airport, NSUInteger idx, BOOL *stop) {
        CLLocationDistance distance = [coordinateLocation distanceFromLocation:airport.location];
        if (distance < nearestDistance) {
            nearestAirport = airport;
            nearestDistance = distance;
        }
    }];
    
    return nearestAirport;
}


#pragma mark - MKMapViewDelegate

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKPlacemark class]]) {
        MKPinAnnotationView *pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"placemark"];
        if (!pin) {
            pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"placemark"];
            pin.pinColor = MKPinAnnotationColorRed;
            pin.canShowCallout = YES;
        } else {
            pin.annotation = annotation;
        }
        return pin;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (_foundLocationCallback) {
        _foundLocationCallback(userLocation.coordinate);
        _foundLocationCallback = nil;
    }
}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self startSearchForText:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        MKMapItem *item = _foundMapItems[buttonIndex];
        NSLog(@"Selected item: %@", item);
        // TODO: Calculate route
        _searchBar.userInteractionEnabled = YES;
    } else {
        _searchBar.userInteractionEnabled = YES;
    }
}

@end
