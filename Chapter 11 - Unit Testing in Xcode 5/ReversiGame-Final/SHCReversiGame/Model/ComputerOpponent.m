//
//  ComputerOpponent.m
//  ReversiGame
//
//  Created by Colin Eberhardt on 02/01/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "ComputerOpponent.h"

typedef struct
{
    NSInteger column;
    NSInteger row;
} Move;


@implementation ComputerOpponent
{
    ReversiBoard* _board;
    BoardCellState _computerColor;
    NSInteger _maxDepth;
}

- (id)initWithBoard:(ReversiBoard *)board color:(BoardCellState)computerColor maxDepth:(NSInteger)depth
{
    if (self = [super init])
    {
        _board = board;
        _computerColor = computerColor;
        _maxDepth = depth;
        [_board.reversiBoardDelegate addDelegate:self];
    }
    return self;
}

- (void) shutdown
{
    if (_board) {
        [_board.reversiBoardDelegate removeDelegate:self];
    }
}

- (void)gameStateChanged
{
    if (_board.nextMove == _computerColor)
    {
        // pause 1 second, then make a move
        [self performSelector:@selector(makeNextMove) withObject:nil afterDelay:1.0];
    }
}

// Determines which move to make
- (void)makeNextMove
{
    Move bestMove = {.column = -1, .row = -1};
    NSInteger bestScore = NSIntegerMin;
    
    // check every valid move for this particular board, then select the one with the best 'score'
    NSArray* moves = [self validMovesForBoard:_board];
    for(NSValue* moveValue in moves)
    {
        Move nextMove;
        [moveValue getValue:&nextMove];
        
        // clone the current board and make this move
        ReversiBoard* testBoard = [_board copyWithZone:nil];
        [testBoard makeMoveToColumn:nextMove.column andRow:nextMove.row];
        
        // determine the score for this move
        NSInteger scoreForMove = [self scoreForBoard:testBoard depth:1];
        
        // pick the best
        if (scoreForMove > bestScore || bestScore == NSIntegerMin)
        {
            bestScore = scoreForMove;
            bestMove.row = nextMove.row;
            bestMove.column = nextMove.column;
        }
    }
    
    if (bestMove.column != -1 && bestMove.row != -1)
    {
        [_board makeMoveToColumn:bestMove.column andRow:bestMove.row];
    }
}

// Computes the score for the given board
- (NSInteger)scoreForBoard:(ReversiBoard*)board depth:(NSInteger)depth
{
    // if we have reached the maximum search depth, then just compute the score of the current
    // board state
    if (depth >= _maxDepth)
    {
        return _computerColor == BoardCellStateWhitePiece ?
        board.whiteScore - board.blackScore :
        board.blackScore - board.whiteScore;
    }
    
    NSInteger minMax = NSIntegerMin;
    
    // check every valid next move for this particular board
    NSArray* moves = [self validMovesForBoard:board];
    for(NSValue* moveValue in moves)
    {
        Move nextMove;
        [moveValue getValue:&nextMove];
        
        // clone the current board and make the move
        ReversiBoard* testBoard = [_board copyWithZone:nil];
        [testBoard makeMoveToColumn:nextMove.column andRow:nextMove.row];
        
        // compute the score for this board
        NSInteger score = [self scoreForBoard:testBoard depth: depth+1];
        
        // pick the best score
        if (depth % 2 == 0)
        {
            if (score > minMax || minMax == NSIntegerMin)
            {
                minMax = score;
            }
        }
        else
        {
            if (score < minMax || minMax == NSIntegerMin)
            {
                minMax = score;
            }
        }
    }
    
    return minMax;
}

// returns an array of valid next moves for the given board
- (NSArray*) validMovesForBoard:(ReversiBoard*) board
{
    NSMutableArray* moves = [[NSMutableArray alloc] init];
    
    for (NSUInteger row = 0; row < 8; row++)
    {
        for (NSUInteger col = 0; col < 8; col++)
        {
            if ([board isValidMoveToColumn:col andRow:row])
            {
                Move move = {.column = col, .row = row};
                [moves addObject:[NSValue valueWithBytes:&move objCType:@encode(Move)]];
            }
        }
    } 
    
    return moves;
}

@end
