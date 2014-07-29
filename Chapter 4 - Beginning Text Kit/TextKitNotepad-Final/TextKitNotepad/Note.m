//
//  CENote.m
//  TextKitNotepad
//
//  Created by Colin Eberhardt on 19/06/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "Note.h"

@implementation Note

+ (Note *)noteWithText:(NSString *)text {
    Note* note = [Note new];
    note.contents = text;
    note.timestamp = [NSDate date];
    return note;
}

- (NSString *)title {
    // split into lines
    NSArray* lines = [self.contents componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    
    // return the first
    return lines[0];
}

@end
