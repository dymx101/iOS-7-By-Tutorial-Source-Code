//
//  Card.m
//  GreatExchange
//
//  Created by Christine Abernathy on 6/30/13.
//  Copyright (c) 2013 Elidora LLC. All rights reserved.
//

#import "Card.h"

@implementation Card

- (void)encodeWithCoder:(NSCoder *)aCoder{
    NSData *imageData = UIImagePNGRepresentation(self.image);
    [aCoder encodeObject:imageData forKey:@"image"];
    [aCoder encodeObject:self.firstName forKey:@"firstName"];
    [aCoder encodeObject:self.lastName forKey:@"lastName"];
    [aCoder encodeObject:self.company forKey:@"company"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeObject:self.website forKey:@"website"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    NSData *imageData = [aDecoder decodeObjectForKey:@"image"];
    self.image = [UIImage imageWithData:imageData];
    self.firstName = [aDecoder decodeObjectForKey:@"firstName"];
    self.lastName = [aDecoder decodeObjectForKey:@"lastName"];
    self.company = [aDecoder decodeObjectForKey:@"company"];
    self.email = [aDecoder decodeObjectForKey:@"email"];
    self.phone = [aDecoder decodeObjectForKey:@"phone"];
    self.website = [aDecoder decodeObjectForKey:@"website"];
    
    return self;
}

@end
