//
//  ObjectWithDate.m
//  Pushitup
//
//  Created by Cesare Rocchi on 7/13/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import "ObjectWithDate.h"

static inline NSDateFormatter *dateFormatter() {
    static NSDateFormatter *_dateFormatter = nil;
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    return _dateFormatter;
}

@implementation ObjectWithDate

- (instancetype) init {
    
    self = [super init];
    
    if (self) {
        
        _date = [NSDate date];
        
    }
    
    return self;
}

- (NSString *) stringDate {
    
    NSDateFormatter *formatter = dateFormatter();
    return [formatter stringFromDate:self.date];
    
}

@end
