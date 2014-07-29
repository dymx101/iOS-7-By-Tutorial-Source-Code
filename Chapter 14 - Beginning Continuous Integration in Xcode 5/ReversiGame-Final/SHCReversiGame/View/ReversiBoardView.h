//
//  ReversiBoardView.h
//  ReversiGame
//
//  Created by Colin Eberhardt on 28/12/2012.
//  Copyright (c) 2012 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReversiBoard.h"

/** A view which renders the Reversi board */
@interface ReversiBoardView : UIView

- (id)initWithFrame:(CGRect)frame andBoard:(ReversiBoard*) board;

@end
