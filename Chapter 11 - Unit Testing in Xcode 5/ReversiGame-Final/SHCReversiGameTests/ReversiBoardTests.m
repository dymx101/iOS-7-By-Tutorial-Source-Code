//
//  ReversiBoardTests.m
//  ReversiGame
//
//  Created by Greg Heo on 2013-07-15.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ReversiBoard.h"

@interface ReversiBoardTests : XCTestCase {
  ReversiBoard *_reversiBoard;
}
@end

@implementation ReversiBoardTests

- (void)setUp
{
    [super setUp];

    _reversiBoard = [[ReversiBoard alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)test_makeMove_inPreGameState_nothingHappens
{
    [_reversiBoard setToPreGameState];

    XCTAssertNoThrowSpecificNamed(
                                  [_reversiBoard makeMoveToColumn:3 andRow:3],
                                  NSException,
                                  NSRangeException,
                                  @"Making a move in the pre-game state should do nothing");
}

@end
