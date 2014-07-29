//
//  GameBoardTests.m
//  ReversiGame
//
//  Created by Greg Heo on 2013-07-15.
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

@end
