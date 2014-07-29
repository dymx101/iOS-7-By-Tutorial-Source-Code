//
//  Card.h
//  GreatExchange
//
//  Created by Christine Abernathy on 6/30/13.
//  Copyright (c) 2013 Elidora LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : NSObject <NSCoding>

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *company;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *website;

@end
