//
//  BookView.h
//  TextKitMagazine
//
//  Created by Colin Eberhardt on 01/07/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewDelegate.h"

@interface BookView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, copy) NSAttributedString* bookMarkup;

@property (nonatomic, weak) id<BookViewDelegate> bookViewDelegate;

- (void)buildFrames;

- (void)navigateToCharacterLocation:(NSUInteger)location;

- (void)removeWordHighlight;

@end
