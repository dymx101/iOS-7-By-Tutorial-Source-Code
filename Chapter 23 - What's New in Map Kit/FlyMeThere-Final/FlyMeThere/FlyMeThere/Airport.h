//
//  Airport.h
//  FlyMeThere
//
//  Created by Matt Galloway on 22/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;
@import MapKit;

@interface Airport : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, strong) CLLocation *location;

@end
