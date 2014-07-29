//
//  BoardDelegate.h
//  ReversiGame
//
//  Created by Colin Eberhardt on 29/12/2012.
//  Copyright (c) 2012 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameStates.h"

@protocol BoardDelegate <NSObject>

- (void)cellStateChanged:(BoardCellState)state forColumn:(int)column andRow:(int) row;

@end
