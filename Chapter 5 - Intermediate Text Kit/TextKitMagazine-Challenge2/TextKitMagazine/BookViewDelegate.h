//
//  BookViewDelegate.h
//  TextKitMagazine
//
//  Created by Colin Eberhardt on 07/07/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BookView;

@protocol BookViewDelegate <NSObject>

- (void)bookView:(BookView *)bookView didHighlightWord:(NSString *)word inRect:(CGRect)rect;

@end
