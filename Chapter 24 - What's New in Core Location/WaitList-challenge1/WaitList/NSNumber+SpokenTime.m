//
//  NSNumber+SpokenTime.m
//  WaitList
//
//  Created by Chris Wagner on 7/25/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "NSNumber+SpokenTime.h"

@implementation NSNumber (SpokenTime)

- (NSString *)spokenTime {
    if ([self floatValue] / 60.0 < 1) {
        return [NSString stringWithFormat:@"%@ minutes", self];
    } else if ([self floatValue] / 60.0 < 2){
        return [NSString stringWithFormat:@"1 hour %d minutes", [self intValue] % 60];
    } else {
        return @"2 hours";
    }
}

@end
