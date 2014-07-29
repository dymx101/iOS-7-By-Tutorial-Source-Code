//
//  ComputerOpponent.h
//  ReversiGame
//
//  Created by Colin Eberhardt on 02/01/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReversiBoardDelegate.h"
#import "ReversiBoard.h"

/** A simple computer opponent. */
@interface ComputerOpponent : NSObject<ReversiBoardDelegate>

- (id) initWithBoard:(ReversiBoard*)board
               color:(BoardCellState)computerColor
            maxDepth:(NSInteger)depth;

- (void) shutdown;

@end
