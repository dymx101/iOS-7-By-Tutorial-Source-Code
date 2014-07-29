//
//  BeaconAdvertisingService.m
//  WaitList
//
//  Created by Chris Wagner on 7/24/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "BeaconAdvertisingService.h"

@import CoreBluetooth;

NSString * const kBeaconIdentifier = @"com.razeware.waitlist";

@interface BeaconAdvertisingService () <CBPeripheralManagerDelegate>

@property (nonatomic, readwrite, getter = isAdvertising) BOOL advertising;

@end

@implementation BeaconAdvertisingService {
    CBPeripheralManager *_peripheralManager;
}

+ (BeaconAdvertisingService *)sharedInstance {
    static BeaconAdvertisingService *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    
    return self;
}


- (void)startAdvertisingUUID:(NSUUID *)uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor {
    
}

- (void)stopAdvertising {
    
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
}

- (BOOL)bluetoothStateValid:(NSError **)error {
    BOOL bluetoothStateValid = YES;
    switch (_peripheralManager.state) {
        case CBPeripheralManagerStatePoweredOff:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.razeware.waitlist.bluetoothstate"
                                             code:CBPeripheralManagerStatePoweredOff
                                         userInfo:@{@"message": @"You must turn Bluetooth on in order to use the beacon feature."}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStateResetting:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.razeware.waitlist.bluetoothstate"
                                             code:CBPeripheralManagerStateResetting
                                         userInfo:@{@"message": @"Bluetooth is not available at this time, please try again in a moment."}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStateUnauthorized:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.razeware.waitlist.bluetoothstate"
                                             code:CBPeripheralManagerStateUnauthorized
                                         userInfo:@{@"message": @"This application is not authorized to use Bluetooth, verify your settings or check with your device's administrator"}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStateUnknown:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.razeware.waitlist.bluetoothstate"
                                             code:CBPeripheralManagerStateUnknown
                                         userInfo:@{@"message": @"Bluetooth is not available at this time, please try again in a moment."}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStateUnsupported:
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.razeware.waitlist.bluetoothstate"
                                             code:CBPeripheralManagerStateUnsupported
                                         userInfo:@{@"message": @"Your device does not support Bluetooth. You will not be able to use the beacon feature."}];
            }
            bluetoothStateValid = NO;
            break;
        case CBPeripheralManagerStatePoweredOn:
            bluetoothStateValid = YES;
            break;
    }
    
    return bluetoothStateValid;
}


@end
