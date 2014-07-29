//
//  Restaurant.h
//  Aroma
//
//  Created by Chris Wagner on 8/3/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Restaurant : NSObject

@property (strong, nonatomic, readonly) NSUUID *uuid;
@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *motdHeader;
@property (strong, nonatomic) NSString *motdBody;

- (instancetype)initWithUUID:(NSUUID *)uuid name:(NSString *)name;

@end
