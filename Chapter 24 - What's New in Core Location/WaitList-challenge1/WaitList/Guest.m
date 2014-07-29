//
//  Guest.m
//  WaitList
//
//  Created by Chris Wagner on 7/25/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "Guest.h"

@implementation Guest

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.partySize = [aDecoder decodeIntegerForKey:@"partySize"];
    self.arrivalTime = [aDecoder decodeObjectForKey:@"arrivalTime"];
    self.quotedTime = [aDecoder decodeObjectForKey:@"quotedTime"];
    self.mood = [aDecoder decodeIntegerForKey:@"mood"];
    self.notes = [aDecoder decodeObjectForKey:@"notes"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInteger:self.partySize forKey:@"partySize"];
    [aCoder encodeObject:self.arrivalTime forKey:@"arrivalTime"];
    [aCoder encodeObject:self.quotedTime forKey:@"quotedTime"];
    [aCoder encodeInteger:self.mood forKey:@"mood"];
    [aCoder encodeObject:self.notes forKey:@"notes"];
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    Guest *g = object;
    if ([g.name isEqual:self.name] &&
        g.partySize == self.partySize &&
        [g.arrivalTime isEqual:self.arrivalTime] &&
        [g.quotedTime isEqual:self.quotedTime] &&
        g.mood == self.mood &&
        [g.notes isEqual:self.notes])
    {
        return YES;
    } else {
        return NO;
    }
}

- (NSUInteger)hash {
    return [self.name hash] ^ self.partySize ^ [self.arrivalTime hash] ^ [self.quotedTime hash] ^ self.mood ^ [self.notes hash];
}

@end
