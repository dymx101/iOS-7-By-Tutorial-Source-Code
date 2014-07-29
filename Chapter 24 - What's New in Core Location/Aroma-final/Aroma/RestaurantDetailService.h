//
//  RestaurantDetailService.h
//  Aroma
//
//  Created by Chris Wagner on 8/3/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Restaurant;

@interface RestaurantDetailService : NSObject

+ (RestaurantDetailService *)sharedService;
- (NSArray *)restaurants;
- (Restaurant *)restaurantWithUUID:(NSUUID *)uuid;

@end
