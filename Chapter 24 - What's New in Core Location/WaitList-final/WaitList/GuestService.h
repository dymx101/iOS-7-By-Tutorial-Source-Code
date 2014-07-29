//
//  GuestService.h
//  WaitList
//
//  Created by Chris Wagner on 7/25/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Guest.h"

@interface GuestService : NSObject

@property (strong, nonatomic, readonly) NSDateFormatter *arrivalDateFormatter;

+ (GuestService *)sharedInstance;
- (void)writeGuestsToDisk;
- (NSArray *)guests;
- (NSInteger)addGuest:(Guest *)guest;
- (void)removeGuest:(Guest *)guest;

@end
