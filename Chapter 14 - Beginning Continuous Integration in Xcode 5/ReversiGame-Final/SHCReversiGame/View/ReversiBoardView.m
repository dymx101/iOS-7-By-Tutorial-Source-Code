//
//  ReversiBoardView.m
//  ReversiGame
//
//  Created by Colin Eberhardt on 28/12/2012.
//  Copyright (c) 2012 Colin Eberhardt. All rights reserved.
//

#import "ReversiBoardView.h"
#import "BoardSquare.h"

@implementation ReversiBoardView

- (id)initWithFrame:(CGRect)frame andBoard:(ReversiBoard *)board
{
    if (self = [super initWithFrame:frame])
    {
        float rowHeight = frame.size.height / 8.0;
        float columnWidth = frame.size.width / 8.0;
        
        // create the 8x8 cells for this board
        for (int row = 0; row < 8; row++)
        {
            for (int col = 0; col < 8; col++)
            {
                BoardSquare* square = [[BoardSquare alloc] initWithFrame:CGRectMake(col*columnWidth, row*rowHeight, columnWidth, rowHeight) column:col row:row board:board];
                [self addSubview:square];
            }
        }
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
