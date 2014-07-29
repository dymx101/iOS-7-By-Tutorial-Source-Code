//
//  SMPushup.h
//  Pushitup
//
//  Created by Cesare Rocchi on 6/26/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectWithDate.h"

@interface Pushup : ObjectWithDate

@property (nonatomic, assign) NSInteger numberOfPushups;

- (instancetype) initWithPushups:(NSInteger) pushups;

@end
