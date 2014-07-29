//
//  ObjectWithDate.h
//  Pushitup
//
//  Created by Cesare Rocchi on 7/13/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectWithDate : NSObject

@property (nonatomic, strong) NSDate *date;

- (NSString *) stringDate;

@end
