//
//  GameBoard.m
//  ReversiGame
//
//  Created by Colin Eberhardt on 27/12/2012.
//  Copyright (c) 2012 Colin Eberhardt. All rights reserved.
//

#import "GameBoard.h"
#import "BoardDelegate.h"

@implementation GameBoard
{
    NSUInteger _board[8][8];
    id<BoardDelegate> _delegate;
}

- (id)init
{
    if (self = [super init]){
        [self clearBoard];
        
        _boardDelegate = [[MulticastDelegate alloc] init];
        _delegate = (id)_boardDelegate;

    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    GameBoard* board = [[[self class] allocWithZone:zone] init];
    memcpy(board->_board, _board, sizeof(NSUInteger) * 8 * 8);
    board->_boardDelegate = [[MulticastDelegate alloc] init];
    board->_delegate = (id)_boardDelegate;
    return board;
}

- (BoardCellState)cellStateAtColumn:(NSInteger)column andRow:(NSInteger)row
{
    [self checkBoundsForColumn:column andRow:row];
    return _board[column][row];
}


- (void)checkBoundsForColumn:(NSInteger)column andRow:(NSInteger)row
{
    if (column < 0 || column > 7 || row < 0 || row > 7)
        [NSException raise:NSRangeException format:@"row or column out of bounds"];
}

- (void)setCellState:(BoardCellState)state forColumn:(NSInteger)column andRow:(NSInteger)row
{
    [self checkBoundsForColumn:column andRow:row];
    _board[column][row] = state;
    [self informDelegateOfStateChanged:state forColumn:column andRow:row];
}


- (void)clearBoard
{
    memset(_board, 0, sizeof(NSInteger) * 8 * 8);
    [self informDelegateOfStateChanged:BoardCellStateEmpty forColumn:-1 andRow:-1];
}

-(void)informDelegateOfStateChanged:(BoardCellState) state forColumn:(NSInteger)column andRow:(NSInteger) row
{
    if ([_delegate respondsToSelector:@selector(cellStateChanged:forColumn:andRow:)]) {
        [_delegate cellStateChanged:state forColumn:column andRow:row];
    }
}

- (NSUInteger) countCellsWithState:(BoardCellState)state
{
    int count = 0;
    for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
            if ([self cellStateAtColumn:col andRow:row] == state) {
                count++;
            }
        }
    }
    return count;
}

@end
