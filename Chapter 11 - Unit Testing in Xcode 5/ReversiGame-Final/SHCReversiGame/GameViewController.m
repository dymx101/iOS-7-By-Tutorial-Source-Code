//
//  GameViewController.m
//  ReversiGame
//
//  Created by Colin Eberhardt on 07/12/2012.
//  Copyright (c) 2012 Colin Eberhardt. All rights reserved.
//

#import "GameViewController.h"
#import "ReversiBoard.h"
#import "ReversiBoardView.h"
#import "ComputerOpponent.h"

@interface GameViewController ()

@end

@implementation GameViewController
{
    ReversiBoard* _board;
    ComputerOpponent* _computer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // create our game board
    _board = [[ReversiBoard alloc] init];
    [_board setToPreGameState];
    
    // create a view
    CGRect boardFrame;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        boardFrame = CGRectMake(88,158,600,585);
    } else {
        boardFrame = _backgroundImage.frame;
        boardFrame.origin.x += 10;
        boardFrame.origin.y += 10;
        boardFrame.size.height = 300;
        boardFrame.size.width = 300;
    }
    ReversiBoardView* reversiBoard = [[ReversiBoardView alloc] initWithFrame:boardFrame andBoard:_board];
    [self.view addSubview:reversiBoard];
    
    [self gameStateChanged];
    [_board.reversiBoardDelegate addDelegate:self];
}

- (IBAction)start2PlayerGame:(id)sender
{
    [_board setToInitialState];
    if (_computer) {
        [_computer shutdown];
        _computer = nil;
    }
    [self gameStateChanged];
}

- (IBAction)startVsComputerGame:(id)sender
{
    [_board setToInitialState];
    if (!_computer) {
      _computer = [[ComputerOpponent alloc] initWithBoard:_board
                                                       color:BoardCellStateWhitePiece
                                                    maxDepth:3];
    }
    [self gameStateChanged];
}

- (void)gameStateChanged
{
    GameState gameState = [_board gameState];

    _gameOverImage.hidden = (gameState != GameStateOver);
    _startButtonsView.hidden = (gameState == GameStateOn);

    _whiteScore.text = [NSString stringWithFormat:@"%d", _board.whiteScore];
    _blackScore.text = [NSString stringWithFormat:@"%d", _board.blackScore];

    if (gameState == GameStateOver) {
        _whiteActive.hidden = YES;
        _blackActive.hidden = YES;
    } else {
        _whiteActive.hidden = _board.nextMove != BoardCellStateWhitePiece;
        _blackActive.hidden = _board.nextMove != BoardCellStateBlackPiece;
    }
}

@end
