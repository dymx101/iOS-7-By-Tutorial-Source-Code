//
//  InterAppAudioUnit.h
//  iGuitar
//
//  Created by Matt Galloway on 23/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AudioUnit.AudioComponent;

@interface InterAppAudioUnit : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) AudioComponentDescription componentDescription;
@property (nonatomic, strong) UIImage *icon;

@end
