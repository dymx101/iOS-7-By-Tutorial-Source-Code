//
//  RestaurantDetailService.m
//  Aroma
//
//  Created by Chris Wagner on 8/3/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "RestaurantDetailService.h"
#import "Restaurant.h"

@implementation RestaurantDetailService {
    NSArray *_restaurants;
}

+ (RestaurantDetailService *)sharedService {
    static dispatch_once_t onceToken;
    static RestaurantDetailService *_sharedService;
    dispatch_once(&onceToken, ^{
        _sharedService = [[self alloc] init];
    });
    
    return _sharedService;
}

- (NSArray *)restaurants {
    if (_restaurants) {
        return _restaurants;
    }

    // load up some static data, ideally this would come from a web service
    NSUUID *cupcakesUUID = [[NSUUID alloc] initWithUUIDString:@"EC6F3659-A8B9-4434-904C-A76F788DAC43"];
    Restaurant *cupcakes = [[Restaurant alloc] initWithUUID:cupcakesUUID name:@"Core Cupcakes"];
    cupcakes.motdHeader = @"Straight to the Core";
    cupcakes.motdBody = @"Our cupcakes our foundational. We consider them to be a core part of everyone's diet. Forget about being in shape... Round is a shape too.";
    cupcakes.image = [UIImage imageNamed:@"Cupcakes"];
    
    NSUUID *saladsUUID = [[NSUUID alloc] initWithUUIDString:@"7B377E4A-1641-4765-95E9-174CD05B6C79"];
    Restaurant *salads = [[Restaurant alloc] initWithUUID:saladsUUID name:@"@synthesize salads"];
    salads.motdHeader = @"Nothing Automatic About Them";
    salads.motdBody = @"You might be used to things being done automatically for you lately. But here at @synthesize salads we aren't lazy and pick our ingredients from the best farming @properties in town.";
    salads.image = [UIImage imageNamed:@"Salad"];
    
    NSUUID *wrapsUUID = [[NSUUID alloc] initWithUUIDString:@"2B144D35-5BA6-4010-B276-FC4D4845B292"];
    Restaurant *wraps = [[Restaurant alloc] initWithUUID:wrapsUUID name:@"Weak Wraps"];
    wraps.motdHeader = @"Retain Cycle Guaranteed";
    wraps.motdBody = @"These wraps are so good, you will wish you had used a weak reference. We guarantee you will be stuck here forever.";
    wraps.image = [UIImage imageNamed:@"Wrap"];
    
    NSUUID *bitesUUID = [[NSUUID alloc] initWithUUIDString:@"A456AF8C-CD6C-4AA8-9AD5-4C8D9C1939D3"];
    Restaurant *bites = [[Restaurant alloc] initWithUUID:bitesUUID name:@"Bitmask Bites"];
    bites.motdHeader = @"0001 | 1000 = 1001";
    bites.motdBody = @"That's how many you should eat, no more, no less.";
    bites.image = [UIImage imageNamed:@"Bites"];
    
    _restaurants = @[cupcakes, wraps, salads, bites];
    
    return _restaurants;
}

- (Restaurant *)restaurantWithUUID:(NSUUID *)uuid {
    if (!_restaurants) {
        [self restaurants];
    }
    
    NSPredicate *uuidPredicate = [NSPredicate predicateWithFormat:@"uuid == %@", uuid];
    Restaurant *restaurant = [[_restaurants filteredArrayUsingPredicate:uuidPredicate] firstObject];
    
    return restaurant;
}

@end
