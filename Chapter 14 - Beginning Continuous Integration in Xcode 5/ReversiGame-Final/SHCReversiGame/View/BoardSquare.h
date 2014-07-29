//
//  BoardSquare.h
//  ReversiGame
//
//  Created by Colin Eberhardt on 28/12/2012.
//  Copyright (c) 2012 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReversiBoard.h"
#import "BoardDelegate.h"

@interface BoardSquare : UIView <BoardDelegate>


- (id) initWithFrame:(CGRect)frame column:(NSInteger)column row:(NSInteger)row board:(ReversiBoard*)board;

@end
