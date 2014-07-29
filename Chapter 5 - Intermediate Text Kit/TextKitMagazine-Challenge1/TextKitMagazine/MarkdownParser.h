//
//  MarkdownParser.h
//  TextKitMagazine
//
//  Created by Colin Eberhardt on 24/06/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarkdownParser : NSObject

- (NSAttributedString*)parseMarkdownFile:(NSString*)path;

@end
