//
//  ReversiBoard.h
//  ReversiGame
//
//  Created by Colin Eberhardt on 28/12/2012.
//  Copyright (c) 2012 Colin Eberhardt. All rights reserved.
//

#import "GameBoard.h"

/** A playing board that board that enforces the rules of the game Reversi. */
@interface ReversiBoard : GameBoard <NSCopying>

// indicates the player who makes the next move
@property (readonly) BoardCellState nextMove;

// Returns whether the player who's turn it is can make the given move
- (BOOL) isValidMoveToColumn:(NSInteger)column andRow:(NSInteger) row;

// Makes the given move for the player who is currently taking their turn
- (void) makeMoveToColumn:(NSInteger) column andRow:(NSInteger)row;

// sets the board to the opening positions for Reversi
- (void) setToInitialState;

- (void) setToPreGameState;

// check and set the current state af the game
- (void)recalculateGameState;

// the current game stata
@property (readonly) GameState gameState;

// the white player's score
@property (readonly) NSInteger whiteScore;

// the black player's score
@property (readonly) NSInteger blackScore;

// multicasts game state changes
@property (readonly) MulticastDelegate* reversiBoardDelegate;

@end
