//
//  BookView.m
//  TextKitMagazine
//
//  Created by Colin Eberhardt on 01/07/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "BookView.h"

@implementation BookView
{
    NSLayoutManager* _layoutManager;
    NSRange _wordCharacterRange;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        
        // add a tap recognizer
        UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

- (void)removeWordHighlight {
    [_layoutManager.textStorage removeAttribute:NSForegroundColorAttributeName range:_wordCharacterRange];
}


-(void)handleTap:(UITapGestureRecognizer*)tapRecognizer {
    
    NSTextStorage* textStorage = _layoutManager.textStorage;
    
    // find the tapped view
    CGPoint tappedLocation = [tapRecognizer locationInView:self];
    UITextView* tappedTextView = nil;
    for (UITextView* textView in [self textSubViews]) {
        if (CGRectContainsPoint(textView.frame, tappedLocation)) {
            tappedTextView = textView;
        }
    }
    
    if (!tappedTextView)
        return;
    
    // determine tap location within the text view
    CGPoint subViewLocation = [tapRecognizer locationInView:tappedTextView];
    subViewLocation.y -= 8.0;
    
    // find the character index
    NSUInteger glyphIndex = [_layoutManager glyphIndexForPoint:subViewLocation inTextContainer:tappedTextView.textContainer];
    NSUInteger charIndex = [_layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    
    if (![[NSCharacterSet letterCharacterSet] characterIsMember:[textStorage.string characterAtIndex:charIndex]])
        return;
    
    // expand to a word range
    _wordCharacterRange = [self wordThatContainsCharacter:charIndex string:textStorage.string];
    
    // highlight the word
    [textStorage addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:_wordCharacterRange];
    
    // line fragment rect
    CGRect rect = [_layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:nil];

    // glyph locations
    NSRange wordGlyphRange = [_layoutManager glyphRangeForCharacterRange:_wordCharacterRange actualCharacterRange:nil];
    CGPoint startLocation =  [_layoutManager locationForGlyphAtIndex:wordGlyphRange.location];
    CGPoint endLocation = [_layoutManager locationForGlyphAtIndex:NSMaxRange(wordGlyphRange)];

    // find the rectangle that surrounds the word
    CGRect wordRect = CGRectMake(startLocation.x, rect.origin.y, endLocation.x - startLocation.x , rect.size.height);

    // offset to the parent coordinate system
    wordRect = CGRectOffset(wordRect, tappedTextView.frame.origin.x, tappedTextView.frame.origin.y);

    // apply the magic margin!
    wordRect = CGRectOffset(wordRect, 0.0, 8.0);

    NSString* word = [textStorage.string substringWithRange:_wordCharacterRange];
    [self.bookViewDelegate bookView:self didHighlightWord:word inRect:wordRect]; 

}

- (NSRange) wordThatContainsCharacter:(NSUInteger)charIndex string:(NSString*)string {
    NSUInteger startLocation = charIndex;
    while(startLocation>0 && [[NSCharacterSet letterCharacterSet] characterIsMember:[string characterAtIndex:startLocation-1]]) {
        startLocation--;
    }
    NSUInteger endLocation = charIndex;
    while(endLocation < string.length && [[NSCharacterSet letterCharacterSet] characterIsMember:[string characterAtIndex:endLocation+1]]) {
        endLocation++;
    }
    return NSMakeRange(startLocation, endLocation-startLocation+1);
}

- (void)buildFrames {
    // create the text storage
    NSTextStorage* textStorage = [[NSTextStorage alloc] initWithAttributedString:self.bookMarkup];
    
    // create the layout manager
    _layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:_layoutManager];
    

    // build the frames
    NSRange range = NSMakeRange(0, 0);
    NSUInteger containerIndex = 0;
    while(NSMaxRange(range) < _layoutManager.numberOfGlyphs) {
        CGRect textViewRect = [self frameForViewAtIndex:containerIndex];
        
        NSTextContainer* textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(textViewRect.size.width, textViewRect.size.height - 16.0f)];
        [_layoutManager addTextContainer:textContainer];
        
        containerIndex++;
        range = [_layoutManager glyphRangeForTextContainer:textContainer];
    }
    
    [self buildViewsForCurrentOffset];
    
    
    self.contentSize = CGSizeMake((self.bounds.size.width / 2)* (CGFloat)containerIndex, self.bounds.size.height);
    self.pagingEnabled = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self buildViewsForCurrentOffset];
}

- (CGRect) frameForViewAtIndex:(NSUInteger)index {
    // create a rectangle that occupies half the screen
    CGRect textViewRect = CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height);
    // inset with the required margins
    textViewRect = CGRectInset(textViewRect, 10.0, 20.0);
    // offset by the required distance
    textViewRect = CGRectOffset(textViewRect, (self.bounds.size.width / 2) * (CGFloat)index, 0.0);
    return textViewRect;
}

- (NSArray*) textSubViews {
    NSMutableArray* views = [NSMutableArray new];
    for (UIView* subview in self.subviews) {
        if ([subview class] == [UITextView class]) {
            [views addObject:subview];
        }
    }
    return views;
}

- (UITextView*) textViewForContainer:(NSTextContainer*)textContainer {
    for (UITextView* textView in [self textSubViews]) {
        if (textView.textContainer == textContainer) {
            return textView;
        }
    }
    return nil;
}

- (BOOL) shouldRenderView:(CGRect) viewFrame {
    
    // check whether the right edge is off to the left of the screem
    if (viewFrame.origin.x + viewFrame.size.width < (self.contentOffset.x - self.bounds.size.width))
        return NO;
    
    // check whether the left edge is off to the right of the screen
    if (viewFrame.origin.x > (self.contentOffset.x + self.bounds.size.width * 2.0))
        return NO;
    
    return YES;
}

- (void) buildViewsForCurrentOffset {
    // 1. iterate over the containers
    for(NSUInteger index = 0; index < _layoutManager.textContainers.count; index++) {
        
        // 2. get the container and view
        NSTextContainer* textContainer = _layoutManager.textContainers[index];
        UITextView* textView = [self textViewForContainer:textContainer];
        
        // 3. determine the required frame
        CGRect textViewRect = [self frameForViewAtIndex:index];
        
        if ([self shouldRenderView:textViewRect]) {
            // 4. this container should be rendered
            if (!textView) {
                NSLog(@"Adding view at index %u", index);
                UITextView* textView = [[UITextView alloc] initWithFrame:textViewRect textContainer:textContainer];
                [self addSubview:textView];
            }
        } else {
            // 5. this container should not be rendered
            if (textView) {
                NSLog(@"Deleting view at index %u", index);
                [textView removeFromSuperview];
            }
        }
    }
}

- (void)navigateToCharacterLocation:(NSUInteger)location {
    CGFloat offset = 0.0f;
    for (NSTextContainer* container in _layoutManager.textContainers) {
        NSRange glyphRange = [_layoutManager glyphRangeForTextContainer:container];
        NSRange charRange = [_layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:nil];
        if (location >= charRange.location && location < NSMaxRange(charRange)) {
            self.contentOffset = CGPointMake(offset, 0);
            [self buildViewsForCurrentOffset];
            return;
        }
        offset += self.bounds.size.width / 2.0f;
    }
}

@end
