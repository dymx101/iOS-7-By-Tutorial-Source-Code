//
//  BeaconAdvertisingService.h
//  WaitList
//
//  Created by Chris Wagner on 7/24/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;

@interface BeaconAdvertisingService : NSObject

@property (nonatomic, readonly, getter = isAdvertising) BOOL advertising;

+ (BeaconAdvertisingService *)sharedInstance;

- (void)startAdvertisingUUID:(NSUUID *)uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor;
- (void)stopAdvertising;

@end
