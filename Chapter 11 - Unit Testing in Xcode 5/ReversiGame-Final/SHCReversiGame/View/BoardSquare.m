//
//  BoardSquare.m
//  ReversiGame
//
//  Created by Colin Eberhardt on 28/12/2012.
//  Copyright (c) 2012 Colin Eberhardt. All rights reserved.
//

#import "BoardSquare.h"

@implementation BoardSquare
{
    int _row;
    int _column;
    ReversiBoard* _board;
    UIImageView* _blackView;
    UIImageView* _whiteView;
}

- (id)initWithFrame:(CGRect)frame column:(NSInteger)column row:(NSInteger)row board:(ReversiBoard *)board
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _row = row;
        _column = column;
        _board = board;
        
        // create the views for the playing piece graphics
        UIImage* blackImage = [UIImage imageNamed: @"ReversiBlackPiece.png"];
        _blackView = [[UIImageView alloc] initWithImage: blackImage];
        _blackView.alpha = 0.0;
        _blackView.frame = self.bounds;
        [self addSubview:_blackView];
        
        UIImage* whiteImage = [UIImage imageNamed: @"ReversiWhitePiece.png"];
        _whiteView = [[UIImageView alloc] initWithImage: whiteImage];
        _whiteView.alpha = 0.0;
        _whiteView.frame = self.bounds;
        [self addSubview:_whiteView];
        
        self.backgroundColor = [UIColor clearColor];
        
        [self update];
        
        [_board.boardDelegate addDelegate:self];
        
        // add a tap recognizer
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(cellTapped:)];
        [self addGestureRecognizer:tapRecognizer];

    }
    return self;
}

// updates the UI state
- (void)update
{
    BoardCellState state = [_board cellStateAtColumn:_column andRow:_row];
    
    [UIView animateWithDuration:0.5f animations:^{
        _whiteView.alpha = state == BoardCellStateWhitePiece ? 1.0 : 0.0;
        _whiteView.transform = state == BoardCellStateWhitePiece ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, -20);
        _blackView.alpha = state == BoardCellStateBlackPiece ? 1.0 : 0.0;
        _blackView.transform = state == BoardCellStateBlackPiece ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, 20);
        
    }];
}

- (void)cellStateChanged:(BoardCellState)state forColumn:(NSInteger)column andRow:(NSInteger)row
{
    if ((column == _column && row == _row) || (column == -1 && row == -1)) {
        [self update];
    }
}

- (void)cellTapped:(UITapGestureRecognizer*)recognizer
{
    if ([_board isValidMoveToColumn:_column andRow:_row]) {
        [_board makeMoveToColumn:_column andRow:_row];
    }
}


@end
