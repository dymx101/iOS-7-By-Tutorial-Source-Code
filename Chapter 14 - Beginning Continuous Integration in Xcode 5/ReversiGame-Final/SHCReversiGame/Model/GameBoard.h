//
//  GameBoard.h
//  ReversiGame
//
//  Created by Colin Eberhardt on 27/12/2012.
//  Copyright (c) 2012 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MulticastDelegate.h"
#import "GameStates.h"

/** An 8x8 playing board. */
@interface GameBoard : NSObject<NSCopying>

// multicasts changes in cell state. Each delegate is informed of changes in state of individual cells.
@property (readonly) MulticastDelegate* boardDelegate;

// gets the state of the cell at the given location
// raises an NSRangeException if the column or row are out of bounds
- (BoardCellState) cellStateAtColumn:(NSInteger)column andRow:(NSInteger)row;

// sets the state of the cell at the given location
// raises an NSRangeException if the column or row are out of bounds
- (void) setCellState:(BoardCellState)state forColumn:(NSInteger)column andRow:(NSInteger)row;

// clears the entire board
- (void) clearBoard;

// counts the number of cells with the given state
- (NSUInteger) countCellsWithState:(BoardCellState) state;

@end
