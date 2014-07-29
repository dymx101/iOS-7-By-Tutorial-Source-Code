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
    _mapView.pitchEnabled = YES;
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
    [_searchBar resignFirstResponder];
    _searchBar.userInteractionEnabled = NO;
    
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    searchRequest.naturalLanguageQuery = searchText;
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (response.mapItems.count > 0) {
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
            
            _foundMapItems = [response.mapItems copy];
            [actionSheet showInView:self.view];
        } else {
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

- (void)setupWithNewRoute:(Route*)route {
    if (_route) {
        [_mapView removeAnnotations:@[_route.source, _route.destination, _route.sourceAirport, _route.destinationAirport]];
        [_mapView removeOverlays:@[_route.toSourceAirportRoute.polyline, _route.flyPartPolyline, _route.fromDestinationAirportRoute.polyline]];
        _route = nil;
    }
    
    _route = route;
    
    [_mapView addAnnotations:@[route.source, route.destination, route.sourceAirport, route.destinationAirport]];
    
    [_mapView addOverlay:route.toSourceAirportRoute.polyline level:MKOverlayLevelAboveRoads];
    [_mapView addOverlay:route.fromDestinationAirportRoute.polyline level:MKOverlayLevelAboveRoads];
    
    [_mapView addOverlay:route.flyPartPolyline level:MKOverlayLevelAboveRoads];
    
    MKMapPoint points[4];
    points[0] = MKMapPointForCoordinate(route.source.coordinate);
    points[1] = MKMapPointForCoordinate(route.destination.coordinate);
    points[2] = MKMapPointForCoordinate(route.sourceAirport.coordinate);
    points[3] = MKMapPointForCoordinate(route.destinationAirport.coordinate);
    
    MKCoordinateRegion boundingRegion = CoordinateRegionBoundingMapPoints(points, 4);
    boundingRegion.span.latitudeDelta *= 1.1f;
    boundingRegion.span.longitudeDelta *= 1.1f;
    [_mapView setRegion:boundingRegion animated:YES];
    
    self.navigationController.toolbarHidden = NO;
}

- (void)obtainDirectionsFrom:(MKMapItem*)from to:(MKMapItem*)to completion:(void(^)(MKRoute *route, NSError *error))completion {
    // 1
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    // 2
    request.source = from;
    request.destination = to;
    
    // 3
    request.transportType = MKDirectionsTransportTypeAutomobile;
    
    // 4
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        MKRoute *route = nil;
        
        // 5
        if (response.routes.count > 0) {
            route = response.routes[0];
        } else if (!error) {
            error = [NSError errorWithDomain:@"com.razeware.FlyMeThere" code:404 userInfo:@{NSLocalizedDescriptionKey:@"No routes found!"}];
        }
        
        // 6
        if (completion) {
            completion(route, error);
        }
    }];
}

- (void)calculateRouteToMapItem:(MKMapItem*)item {
    // 1
    [self performAfterFindingLocation:^(CLLocationCoordinate2D userLocation) {
        // 2
        MKPointAnnotation *sourceAnnotation = [MKPointAnnotation new];
        sourceAnnotation.coordinate = userLocation;
        sourceAnnotation.title = @"Start";
        
        MKPointAnnotation *destinationAnnotation = [MKPointAnnotation new];
        destinationAnnotation.coordinate = item.placemark.coordinate;
        destinationAnnotation.title = @"End";
        
        // 3
        Airport *sourceAirport = [self nearestAirportToCoordinate:userLocation];
        Airport *destinationAirport = [self nearestAirportToCoordinate:item.placemark.coordinate];
        
        // 1
        MKMapItem *sourceMapItem = [self mapItemForCoordinate:userLocation];
        MKMapItem *destinationMapItem = item;
        
        // 2
        MKMapItem *sourceAirportMapItem = [self mapItemForCoordinate:sourceAirport.coordinate];
        sourceAirportMapItem.name = sourceAirport.title;
        
        MKMapItem *destinationAirportMapItem = [self mapItemForCoordinate:destinationAirport.coordinate];
        destinationAirportMapItem.name = destinationAirport.title;
        
        __block MKRoute *toSourceAirportDirectionsRoute = nil;
        __block MKRoute *fromDestinationAirportDirectionsRoute = nil;
        
        // 3
        dispatch_group_t group = dispatch_group_create();
        
        // 4
        // Find route to source airport
        dispatch_group_enter(group);
        [self obtainDirectionsFrom:sourceMapItem
                                to:sourceAirportMapItem
                        completion:^(MKRoute *route, NSError *error) {
                            toSourceAirportDirectionsRoute = route;
                            dispatch_group_leave(group);
                        }];
        
        // 5
        // Find route from destination airport
        dispatch_group_enter(group);
        [self obtainDirectionsFrom:destinationAirportMapItem
                                to:destinationMapItem
                        completion:^(MKRoute *route, NSError *error) {
                            fromDestinationAirportDirectionsRoute = route;
                            dispatch_group_leave(group);
                        }];
        
        // 6
        // When both are found, setup new route
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (toSourceAirportDirectionsRoute && fromDestinationAirportDirectionsRoute) {
                Route *route = [Route new];
                route.source = sourceAnnotation;
                route.destination = destinationAnnotation;
                route.sourceAirport = sourceAirport;
                route.destinationAirport = destinationAirport;
                route.toSourceAirportRoute = toSourceAirportDirectionsRoute;
                route.fromDestinationAirportRoute = fromDestinationAirportDirectionsRoute;
                
                CLLocationCoordinate2D coords[2] = {sourceAirport.coordinate, destinationAirport.coordinate};
                route.flyPartPolyline = [MKGeodesicPolyline polylineWithCoordinates:coords count:2];
                
                [self setupWithNewRoute:route];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                message:@"Failed to find directions! Please try again."
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
                [alert show];
            }
            
            _searchBar.userInteractionEnabled = YES;
        });
    }];
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

- (void)moveCameraToCoordinate:(CLLocationCoordinate2D)coordinate {
    // 1
    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:coordinate
                                                     fromEyeCoordinate:coordinate
                                                           eyeAltitude:1000.0];
    
    // 2
    camera.pitch = 55.0f;
    
    // 3
    [UIView animateWithDuration:1.0
                     animations:^{
                         // 4
                         _mapView.camera = camera;
                     }];
}


#pragma mark - Actions

- (IBAction)startTapped:(id)sender {
    [self moveCameraToCoordinate:_route.source.coordinate];
}

- (IBAction)airportATapped:(id)sender {
    [self moveCameraToCoordinate:_route.sourceAirport.coordinate];
}

- (IBAction)airportBTapped:(id)sender {
    [self moveCameraToCoordinate:_route.destinationAirport.coordinate];
}

- (IBAction)endTapped:(id)sender {
    [self moveCameraToCoordinate:_route.destination.coordinate];
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

- (MKOverlayRenderer*)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline*)overlay];
        
        if (overlay == _route.flyPartPolyline) {
            renderer.strokeColor = [UIColor redColor];
        } else {
            renderer.strokeColor = [UIColor blueColor];
        }
        
        return renderer;
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
        [self calculateRouteToMapItem:item];
    } else {
        _searchBar.userInteractionEnabled = YES;
    }
}

@end
