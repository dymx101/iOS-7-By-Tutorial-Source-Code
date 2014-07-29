//
//  MulticastDelegate.h
//  ClearStyle
//
//  Created by Colin Eberhardt on 13/11/2012.
//  Copyright (c) 2012 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

/** handles messages sent to delegates, multicasting these messages to multiple observers. */
@interface MulticastDelegate : NSObject

// Adds the given delegate implementation to the list of observers
- (void)addDelegate:(id)delegate;

- (void)removeDelegate:(id)delegate;

@end
