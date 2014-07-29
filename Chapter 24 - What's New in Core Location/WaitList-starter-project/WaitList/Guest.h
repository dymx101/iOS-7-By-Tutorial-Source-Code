//
//  Guest.h
//  WaitList
//
//  Created by Chris Wagner on 7/25/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Guest : NSObject <NSCoding>

@property (strong, nonatomic) NSString *name;
@property (nonatomic) NSInteger partySize;
@property (strong, nonatomic) NSDate *arrivalTime;
@property (strong, nonatomic) NSNumber *quotedTime;
@property (nonatomic) NSInteger mood;
@property (strong, nonatomic) NSString *notes;

@end
