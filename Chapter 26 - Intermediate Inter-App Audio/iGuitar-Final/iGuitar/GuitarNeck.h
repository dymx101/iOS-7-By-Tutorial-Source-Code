//
//  GuitarNeck.h
//  iGuitar
//
//  Created by Matt Galloway on 22/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GuitarNeck;

@protocol GuitarNeckDelegate <NSObject>
@optional
- (void)guitarNeck:(GuitarNeck *)guitarNeck didStartNote:(NSUInteger)note;
- (void)guitarNeck:(GuitarNeck *)guitarNeck didStopNote:(NSUInteger)note;
@end

@interface GuitarNeck : UIView

@property (nonatomic, weak) id <GuitarNeckDelegate> delegate;

- (void)playChord:(NSString*)chord;

@end
