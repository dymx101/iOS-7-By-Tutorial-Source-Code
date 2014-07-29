//
//  GameStates.h
//  ReversiGame
//
//  Created by Colin Eberhardt on 27/12/2012.
//  Copyright (c) 2012 Colin Eberhardt. All rights reserved.
//

#ifndef SHCReversiGame_GameStates_h
#define SHCReversiGame_GameStates_h

typedef NS_ENUM(NSUInteger, BoardCellState) {
    BoardCellStateEmpty = 0,
    BoardCellStateBlackPiece = 1,
    BoardCellStateWhitePiece = 2
};

typedef NS_ENUM(NSUInteger, GameState) {
  GameStatePreGame = 0,
  GameStateOn,
  GameStateOver
};

#endif
