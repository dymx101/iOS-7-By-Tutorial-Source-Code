//
//  ReversiBoard.m
//  ReversiGame
//
//  Created by Colin Eberhardt on 28/12/2012.
//  Copyright (c) 2012 Colin Eberhardt. All rights reserved.
//

#import "ReversiBoard.h"
#import "ReversiBoardDelegate.h"

// A 'navigation' function. This takes the given row / column values and navigates in one of the 8 possible directions across the playing board.
typedef void (^BoardNavigationFunction)(NSInteger*, NSInteger*);

BoardNavigationFunction BoardNavigationFunctionRight = ^(NSInteger* c, NSInteger* r) {
    (*c)++;
};

BoardNavigationFunction BoardNavigationFunctionLeft = ^(NSInteger* c, NSInteger* r) {
    (*c)--;
};

BoardNavigationFunction BoardNavigationFunctionUp = ^(NSInteger* c, NSInteger* r) {
    (*r)--;
};

BoardNavigationFunction BoardNavigationFunctionDown = ^(NSInteger* c, NSInteger* r) {
    (*r)++;
};

BoardNavigationFunction BoardNavigationFunctionRightUp = ^(NSInteger* c, NSInteger* r) {
    (*c)++;
    (*r)--;
};

BoardNavigationFunction BoardNavigationFunctionRightDown = ^(NSInteger* c, NSInteger* r) {
    (*c)++;
    (*r)++;
};

BoardNavigationFunction BoardNavigationFunctionLeftUp = ^(NSInteger* c, NSInteger* r) {
    (*c)--;
    (*r)++;
};

BoardNavigationFunction BoardNavigationFunctionLeftDown = ^(NSInteger* c, NSInteger* r) {
    (*c)--;
    (*r)--;
};

@implementation ReversiBoard {
    BoardNavigationFunction _boardNavigationFunctions[8];
    id<ReversiBoardDelegate> _delegate;
}

- (id)init
{
    if (self = [super init]) {
        [self commonInit];
        [self setToPreGameState];
    }
    return self;
}

- (void)commonInit
{
    // create an array of all 8 navigation functions
    _boardNavigationFunctions[0]=BoardNavigationFunctionUp;
    _boardNavigationFunctions[1]=BoardNavigationFunctionDown;
    _boardNavigationFunctions[2]=BoardNavigationFunctionLeft;
    _boardNavigationFunctions[3]=BoardNavigationFunctionRight;
    _boardNavigationFunctions[4]=BoardNavigationFunctionLeftDown;
    _boardNavigationFunctions[5]=BoardNavigationFunctionLeftUp;
    _boardNavigationFunctions[6]=BoardNavigationFunctionRightDown;
    _boardNavigationFunctions[7]=BoardNavigationFunctionRightUp;
    
    _reversiBoardDelegate = [[MulticastDelegate alloc] init];
    _delegate = (id)_reversiBoardDelegate; 
}

- (id)copyWithZone:(NSZone *)zone
{
    ReversiBoard* board = [super copyWithZone:zone];
    board->_nextMove = _nextMove;
    board->_whiteScore = _whiteScore;
    board->_blackScore = _blackScore;
    return board;
}

- (void)setToInitialState
{
    // clear the board
    [super clearBoard];
    
    // add initial play counters
    [super setCellState:BoardCellStateWhitePiece forColumn:3 andRow:3];
    [super setCellState:BoardCellStateBlackPiece forColumn:4 andRow:3];
    [super setCellState:BoardCellStateBlackPiece forColumn:3 andRow:4];
    [super setCellState:BoardCellStateWhitePiece forColumn:4 andRow:4];
    
    _whiteScore = 2;
    _blackScore = 2;
    
    _nextMove = BoardCellStateBlackPiece;
    _gameState = GameStateOn;
}

- (void) setToPreGameState
{
    // clear the board
    [super clearBoard];

    _nextMove = BoardCellStateEmpty;
    _gameState = GameStatePreGame;
}

- (BOOL)isValidMoveToColumn:(int)column andRow:(int) row;
{
    return [self isValidMoveToColumn:column andRow:row forState:self.nextMove];
}

- (BOOL)isValidMoveToColumn:(int)column andRow:(int)row forState:(BoardCellState)state
{
    // check the cell is empty
    if ([super cellStateAtColumn:column andRow:row] != BoardCellStateEmpty)
        return NO;
    
    // check each direction
    for (int i=0;i<8;i++) {
        if ([self moveSurroundsCountersForColumn:column
                                          andRow:row
                          withNavigationFunction:_boardNavigationFunctions[i]
                                         toState:state])
        {
            return YES;
        }
    }
    
    // if no directions are valid - then this is not a valid move
    return NO;
}


- (void)makeMoveToColumn:(NSInteger)column andRow:(NSInteger)row
{
    if ([self gameState] != GameStateOn)
        return;
    
    // place the playing piece at the given location
    [self setCellState:self.nextMove forColumn:column  andRow:row];
    
    // check the 8 play directions and flip pieces
    for (int i=0; i<8; i++) {
        [self flipOpponentCountersForColumn:column
                                      andRow:row
                      withNavigationFunction:_boardNavigationFunctions[i]
                                     toState:self.nextMove];
    }
    
    [self switchTurns];

    [self recalculateGameState];
    
    _whiteScore = [self countCellsWithState:BoardCellStateWhitePiece];
    _blackScore = [self countCellsWithState:BoardCellStateBlackPiece];
    
    if ([_delegate respondsToSelector:@selector(gameStateChanged)]) {
        [_delegate gameStateChanged];
    }
}

- (void) switchTurns
{
    // switch players
    BoardCellState nextMoveTemp = [self invertState:self.nextMove];
    
    // only switch play if this player can make a move
    if ([self canPlayerMakeAMove:nextMoveTemp]) {
        _nextMove = nextMoveTemp;
    }
}


- (BoardCellState) invertState: (BoardCellState)state
{
    if (state == BoardCellStateBlackPiece)
        return BoardCellStateWhitePiece;
    
    if (state == BoardCellStateWhitePiece)
        return BoardCellStateBlackPiece;
    
    return BoardCellStateEmpty;
}

- (BOOL) moveSurroundsCountersForColumn:(NSInteger) column andRow:(NSInteger)row withNavigationFunction:(BoardNavigationFunction) navigationFunction toState:(BoardCellState) state
{
    NSInteger index = 1;
    
    // advance to the next cell
    navigationFunction(&column, &row);
    
    // while within the bounds of the board
    while(column>=0 && column<=7 && row>=0 && row<=7) {
        BoardCellState currentCellState = [super cellStateAtColumn:column andRow:row];
        
        // the cell that is the immediate neighbour must be of the other colour
        if (index == 1) {
            if (currentCellState!=[self invertState:state]) {
                return NO;
            }
        } else {
            // if we have reached a cell of the same colour, this is a valid move
            if (currentCellState==state) {
                return YES;
            }
            
            // if we have reached an empty cell - fail
            if (currentCellState==BoardCellStateEmpty) {
                return NO;
            }
        }
        
        index++;
        
        // advance to the next cell
        navigationFunction(&column, &row);
    }
    
    return NO;
}

- (void) flipOpponentCountersForColumn:(int) column andRow:(int)row withNavigationFunction:(BoardNavigationFunction) navigationFunction toState:(BoardCellState) state
{
    // are any pieces surrounded in this direction?
    if (![self moveSurroundsCountersForColumn:column
                                       andRow:row
                       withNavigationFunction:navigationFunction
                                      toState:state])
        return;
    
    BoardCellState opponentsState = [self invertState:state];
    BoardCellState currentCellState;
    
    // flip counters until the edge of the boards is reached, or
    // a piece of the current state is reached
    do {
        // advance to the next cell
        navigationFunction(&column, &row);
        currentCellState = [super cellStateAtColumn:column andRow:row];
        [self setCellState:state forColumn:column  andRow:row];
    } while(column>=0 && column<=7 &&
            row>=0 && row<=7 &&
            currentCellState == opponentsState);
}

- (void)recalculateGameState
{
    if (_nextMove == BoardCellStateEmpty)
        _gameState = GameStatePreGame;
    else if ([self canPlayerMakeAMove:BoardCellStateBlackPiece] || [self canPlayerMakeAMove:BoardCellStateWhitePiece])
        _gameState = GameStateOn;
    else
        _gameState = GameStateOver;
}

- (BOOL) canPlayerMakeAMove:(BoardCellState) state
{
    // test all the board locations to see if a move can be made
    for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
            if ([self isValidMoveToColumn:col andRow:row forState:state]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
