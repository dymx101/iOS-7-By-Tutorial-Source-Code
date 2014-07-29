//
//  Restaurant.m
//  Aroma
//
//  Created by Chris Wagner on 8/3/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant

- (instancetype)initWithUUID:(NSUUID *)uuid name:(NSString *)name {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _uuid = uuid;
    _name = name;
    
    return self;
}

@end
