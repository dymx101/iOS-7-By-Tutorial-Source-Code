//
//  ReversiBoardDelegate.h
//  ReversiGame
//
//  Created by Colin Eberhardt on 31/12/2012.
//  Copyright (c) 2012 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

/** A delegate that informs of game state changes */
@protocol ReversiBoardDelegate <NSObject>

// indicates that the game state has changed
- (void) gameStateChanged;

@end
