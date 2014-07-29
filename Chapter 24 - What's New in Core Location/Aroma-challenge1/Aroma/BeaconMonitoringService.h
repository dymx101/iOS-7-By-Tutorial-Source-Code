//
//  BeaconMonitoringService.h
//  Aroma
//
//  Created by Chris Wagner on 8/12/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;

@interface BeaconMonitoringService : NSObject

+ (BeaconMonitoringService *)sharedInstance;
- (void)startMonitoringBeaconWithUUID:(NSUUID *)uuid
                                major:(CLBeaconMajorValue)major
                                minor:(CLBeaconMinorValue)minor
                           identifier:(NSString *)identifier
                              onEntry:(BOOL)entry
                               onExit:(BOOL)exit;

- (void)stopMonitoringAllRegions;

@end
