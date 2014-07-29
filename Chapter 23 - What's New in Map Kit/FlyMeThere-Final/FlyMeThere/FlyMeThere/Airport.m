//
//  Airport.m
//  FlyMeThere
//
//  Created by Matt Galloway on 22/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import "Airport.h"

@implementation Airport

#pragma mark - MKAnnotation

- (NSString*)title {
    return [NSString stringWithFormat:@"%@ (%@)", _name, _code];
}

- (CLLocationCoordinate2D)coordinate {
    return _location.coordinate;
}

@end
