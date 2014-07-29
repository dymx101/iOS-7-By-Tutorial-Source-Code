//
//  Route.h
//  FlyMeThere
//
//  Created by Matt Galloway on 28/07/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Airport;
@class MKPointAnnotation;
@class MKRoute;
@class MKGeodesicPolyline;

@interface Route : NSObject

@property (nonatomic, strong) MKPointAnnotation *source;
@property (nonatomic, strong) MKPointAnnotation *destination;
@property (nonatomic, strong) Airport *sourceAirport;
@property (nonatomic, strong) Airport *destinationAirport;

@property (nonatomic, strong) MKRoute *toSourceAirportRoute;
@property (nonatomic, strong) MKGeodesicPolyline *flyPartPolyline;
@property (nonatomic, strong) MKRoute *fromDestinationAirportRoute;

@end
