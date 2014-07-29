//
//  GameBoardTests.m
//  ReversiGame
//
//  Created by Greg Heo on 2013-07-11.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GameBoard.h"

@interface GameBoardTests : XCTestCase {
    GameBoard *_board;
}
@end

@implementation GameBoardTests

- (void)setUp
{
    [super setUp];

    _board = [[GameBoard alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)test_setAndGetCellState_setValidCell_cellStateChanged
{
    [_board setCellState:BoardCellStateWhitePiece forColumn:4 andRow:5];

    BoardCellState retrievedState = [_board cellStateAtColumn:4 andRow:5];
    XCTAssertEqual(BoardCellStateWhitePiece, retrievedState, @"The cell should be white!");
}

- (void)test_setCellState_withInvalidCoords_exceptionThrown
{
    XCTAssertThrowsSpecificNamed([_board setCellState:BoardCellStateBlackPiece forColumn:10 andRow:7],
                                 NSException,
                                 NSRangeException,
                                 @"Out-of-bounds board set should raise an exception");
}

- (void)test_getCellState_withInvalidCoords_exceptionThrown
{
    XCTAssertThrowsSpecificNamed([_board cellStateAtColumn:7 andRow:-10],
                                 NSException,
                                 NSRangeException,
                                 @"Out-of-bounds board access should raise an exception");
}

// Challenge #1
- (void)test_clearBoard_clearPlayedBoard_boardCleared
{
    [_board setCellState:BoardCellStateWhitePiece forColumn:1 andRow:3];
    [_board setCellState:BoardCellStateBlackPiece forColumn:2 andRow:5];

    [_board clearBoard];

    BoardCellState retrievedState;

    retrievedState = [_board cellStateAtColumn:1 andRow:3];
    XCTAssertEqual(BoardCellStateEmpty, retrievedState, @"The board should have been cleared!");
    retrievedState = [_board cellStateAtColumn:2 andRow:5];
    XCTAssertEqual(BoardCellStateEmpty, retrievedState, @"The board should have been cleared!");
}

// Challenge #2
- (void)test_countCells_withPlayedBoard_correctCountCalculated
{
    [_board setCellState:BoardCellStateWhitePiece forColumn:1 andRow:1];
    [_board setCellState:BoardCellStateWhitePiece forColumn:1 andRow:2];
    [_board setCellState:BoardCellStateBlackPiece forColumn:3 andRow:1];

    XCTAssert([_board countCellsWithState:BoardCellStateWhitePiece] == 2, @"White should have 2 pieces played");
    XCTAssert([_board countCellsWithState:BoardCellStateBlackPiece] == 1, @"Black should have 1 piece played");
}

@end
