//
//  GuestService.m
//  WaitList
//
//  Created by Chris Wagner on 7/25/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "GuestService.h"

@implementation GuestService {
    NSMutableArray *_guests;
    NSString *_guestsFilePath;
}

+ (GuestService *)sharedInstance {
    static dispatch_once_t onceToken;
    static GuestService *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _guestsFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/guests.dat"];
    _guests = [[NSKeyedUnarchiver unarchiveObjectWithFile:_guestsFilePath] mutableCopy];
    
    _arrivalDateFormatter = [[NSDateFormatter alloc] init];
    [_arrivalDateFormatter setDateFormat:@"hh:mm a"];
    
    if (!_guests) {
        _guests = [NSMutableArray array];
    }
    
    return self;
}

- (void)writeGuestsToDisk {
    NSData *guestsData = [NSKeyedArchiver archivedDataWithRootObject:_guests];
    if ([guestsData writeToFile:_guestsFilePath atomically:YES]) {
        NSLog(@"Guest data persisted to disk");
    } else {
        NSLog(@"Could not persist guest data to disk");
    }
}

- (NSArray *)guests {
    return [_guests copy];
}

- (NSInteger)addGuest:(Guest *)guest {
    NSInteger index = [_guests indexOfObject:guest
             inSortedRange:NSMakeRange(0, _guests.count)
                   options:NSBinarySearchingInsertionIndex
           usingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        Guest *g1 = obj1;
        Guest *g2 = obj2;
        
        return [g1.arrivalTime compare:g2.arrivalTime];
    }];
    
    [_guests insertObject:guest atIndex:index];
    [self writeGuestsToDisk];
    
    return index;
}

- (void)removeGuest:(Guest *)guest {
    [_guests removeObject:guest];
    [self writeGuestsToDisk];
}

@end
