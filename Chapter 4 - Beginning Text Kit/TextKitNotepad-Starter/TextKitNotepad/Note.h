//
//  CENote.h
//  TextKitNotepad
//
//  Created by Colin Eberhardt on 19/06/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Note : NSObject

@property NSString* contents;
@property NSDate* timestamp;

// an automatically generated not title, based on the first few words
@property (readonly) NSString* title;

+ (Note*) noteWithText:(NSString*)text;

@end
