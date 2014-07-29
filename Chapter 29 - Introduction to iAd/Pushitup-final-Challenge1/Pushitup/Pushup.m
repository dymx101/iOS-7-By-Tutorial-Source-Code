//
//  SMPushup.m
//  Pushitup
//
//  Created by Cesare Rocchi on 6/26/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import "Pushup.h"

@implementation Pushup

- (instancetype) initWithPushups:(NSInteger) pushups {

    self = [super init];
    
    if (self) {
        
        _numberOfPushups = pushups;
        
    }
    
    return self;
    
}



@end
