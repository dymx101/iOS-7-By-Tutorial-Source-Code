//
//  MapKitHelpers.m
//  FlyMeThere
//
//  Created by Matt Galloway on 28/07/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import "MapKitHelpers.h"

MKCoordinateRegion CoordinateRegionBoundingMapPoints(MKMapPoint *points, NSUInteger count) {
    if (count == 0) {
        return MKCoordinateRegionForMapRect(MKMapRectWorld);
    }
    
    MKMapRect boundingMapRect;
    boundingMapRect.origin = points[0];
    boundingMapRect.size = MKMapSizeMake(0.0, 0.0);
    
    for (NSUInteger i = 1; i < count; i++) {
        MKMapPoint point = points[i];
        if (!MKMapRectContainsPoint(boundingMapRect, point)) {
            boundingMapRect = MKMapRectUnion(boundingMapRect, (MKMapRect){.origin=point,.size={0.0,0.0}});
        }
    }
    
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(boundingMapRect);
    region.span.latitudeDelta = MAX(region.span.latitudeDelta, 0.001);
    region.span.longitudeDelta = MAX(region.span.longitudeDelta, 0.001);
    
    return region;
}
