//
//  GuitarNeck.m
//  iGuitar
//
//  Created by Matt Galloway on 22/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import "GuitarNeck.h"

@interface Note : NSObject
@property (nonatomic, assign, readonly) NSInteger fret;
@property (nonatomic, assign, readonly) NSInteger string;
@property (nonatomic, assign, readonly) NSUInteger noteNumber;
@end

@implementation Note

- (instancetype)initWithFret:(NSInteger)fret onString:(NSInteger)string {
    if ((self = [super init])) {
        _fret = fret;
        _string = string;
    }
    return self;
}

- (NSUInteger)hash {
    return _fret << 3 | _string;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    Note *other = (Note*)object;
    
    return (_fret == other.fret && _string == other.string);
}

- (NSUInteger)noteNumber {
    NSUInteger startNote = 0;
    switch (_string) {
        case 0:
        default:
            startNote = 40; break;
        case 1:
            startNote = 45; break;
        case 2:
            startNote = 50; break;
        case 3:
            startNote = 55; break;
        case 4:
            startNote = 59; break;
        case 5:
            startNote = 64; break;
    }
    
    return startNote + _fret;
}

@end

static const CGFloat kFretAspectRatio = 80.0f / 160.0f;
static const CGFloat kNeckHeightRatio = 0.5f;
static UIColor *kNeckColor = nil;
static UIColor *kFretColor = nil;
static UIColor *kStringColor = nil;
static UIColor *kFretDotColor = nil;

@implementation GuitarNeck {
    NSMutableDictionary *_stickyNotes;
    NSMutableDictionary *_touchedNotes;
    NSMutableSet *_strummingTouches;
    NSMutableDictionary *_playingNotes;
    NSMutableDictionary *_playingNotesStopTimers;
}

#pragma mark -

+ (void)initialize {
    if (self == [GuitarNeck class]) {
        kNeckColor = [UIColor colorWithRed:(25.0f/255.0f) green:(25.0f/255.0f) blue:(25.0f/255.0f) alpha:1.0f];
        kFretColor = [UIColor colorWithRed:(37.0f/255.0f) green:(37.0f/255.0f) blue:(37.0f/255.0f) alpha:1.0f];
        kStringColor = [UIColor colorWithRed:(152.0f/255.0f) green:(152.0f/255.0f) blue:(152.0f/255.0f) alpha:1.0f];
        kFretDotColor = [UIColor colorWithRed:(48.0f/255.0f) green:(50.0f/255.0f) blue:(52.0f/255.0f) alpha:1.0f];
    }
}


#pragma mark -

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self initialiser];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self initialiser];
    }
    return self;
}

- (void)initialiser {
    _stickyNotes = [NSMutableDictionary new];
    _touchedNotes = [NSMutableDictionary new];
    _strummingTouches = [NSMutableSet new];
    _playingNotes = [NSMutableDictionary new];
    _playingNotesStopTimers = [NSMutableDictionary new];
    
    for (int i = 0; i < 6; i++) {
        _touchedNotes[@(i)] = [NSMutableSet new];
    }
    
    self.multipleTouchEnabled = YES;
}

- (void)drawRect:(CGRect)rect {
    const CGRect bounds = self.bounds;
    
    const CGFloat neckHeight = CGRectGetHeight(bounds) * kNeckHeightRatio;
    const CGFloat neckYOffset = (CGRectGetHeight(bounds) - neckHeight) / 2.0f;
    const CGRect neckFrame = CGRectMake(0.0f, neckYOffset, CGRectGetWidth(bounds), neckHeight);
    
    const CGFloat fretWidth = CGRectGetHeight(neckFrame) * kFretAspectRatio;
    const CGFloat topWidth = fretWidth / 2.0f;
    const CGFloat stringHeight = CGRectGetHeight(neckFrame) / 6.0f;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw the background
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, kNeckColor.CGColor);
    CGContextFillRect(context, neckFrame);
    CGContextRestoreGState(context);
    
    // Draw the top
    CGContextSaveGState(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 6.0f);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetWidth(neckFrame) - 3.0f, CGRectGetMinY(neckFrame));
    CGContextAddLineToPoint(context, CGRectGetWidth(neckFrame) - 3.0f, CGRectGetMaxY(neckFrame));
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 3.0f);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetWidth(neckFrame) - topWidth, CGRectGetMinY(neckFrame));
    CGContextAddLineToPoint(context, CGRectGetWidth(neckFrame) - topWidth, CGRectGetMaxY(neckFrame));
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    
    // Draw the frets
    CGFloat currentX = CGRectGetWidth(neckFrame) - topWidth;
    NSUInteger fret = 1;
    while (currentX > 0.0f) {
        CGContextSaveGState(context);
        
        CGContextSetStrokeColorWithColor(context, kFretColor.CGColor);
        CGContextSetLineWidth(context, 2.0f);
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, currentX, CGRectGetMinY(neckFrame));
        CGContextAddLineToPoint(context, currentX, CGRectGetMaxY(neckFrame));
        CGContextStrokePath(context);
        
        CGContextRestoreGState(context);
        
        if (fret == 3 || fret == 5 || fret == 7 || fret == 9) {
            const CGFloat radius = (stringHeight / 2.0f) * 0.8f;
            
            CGPoint point;
            point.x = CGRectGetWidth(neckFrame) - topWidth - (fretWidth * ((CGFloat)(fret - 1) + 0.5f));
            point.y = CGRectGetMinY(neckFrame) + (CGRectGetHeight(neckFrame) / 2.0f);
            
            CGContextSaveGState(context);
            
            CGContextSetFillColorWithColor(context, kFretDotColor.CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(point.x - radius,
                                                           point.y - radius,
                                                           radius * 2.0f,
                                                           radius * 2.0f));
            
            CGContextRestoreGState(context);
        }
        
        currentX -= fretWidth;
        fret++;
    }
    
    // Draw the strings
    for (int i = 0; i < 6; i++) {
        int stringWidth = 6 - i;
        stringWidth = MAX(stringWidth, 2);
        stringWidth = MIN(stringWidth, 5);
        
        CGFloat thisStringMiddle = CGRectGetMinY(neckFrame) + (stringHeight * ((CGFloat)i + 0.5f));
        if (stringWidth % 2 == 0) {
            thisStringMiddle -= 0.5f;
        }
        
        CGContextSaveGState(context);
        
        CGContextSetStrokeColorWithColor(context, kStringColor.CGColor);
        CGContextSetLineWidth(context, (CGFloat)stringWidth);
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0.0f, thisStringMiddle);
        CGContextAddLineToPoint(context, CGRectGetWidth(bounds), thisStringMiddle);
        CGContextStrokePath(context);
        
        CGContextRestoreGState(context);
    }
    
    // Draw the playing notes
    for (NSInteger i = 0; i < 6; i++) {
        Note *note = _stickyNotes[@(i)];
        if (!note) {
            note = [[Note alloc] initWithFret:0 onString:i];
        }
        
        const CGFloat radius = (stringHeight / 2.0f) * 0.8f;
        
        CGPoint point;
        if (note.fret == 0) {
            point.x = CGRectGetWidth(neckFrame) - (topWidth / 2.0f);
        } else {
            point.x = CGRectGetWidth(neckFrame) - topWidth - (fretWidth * ((CGFloat)(note.fret - 1) + 0.5f));
        }
        point.y = CGRectGetMinY(neckFrame) + (stringHeight * ((CGFloat)note.string + 0.5f));
        
        CGContextSaveGState(context);
        
        CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(point.x - radius,
                                                       point.y - radius,
                                                       radius * 2.0f,
                                                       radius * 2.0f));
        
        CGContextRestoreGState(context);
    }
    
    // Draw the touched notes
    for (NSInteger i = 0; i < 6; i++) {
        NSMutableSet *touchedNotes = _touchedNotes[@(i)];
        [touchedNotes enumerateObjectsUsingBlock:^(Note *note, BOOL *stop) {
            const CGFloat radius = (stringHeight / 2.0f) * 0.6f;
            
            CGPoint point;
            if (note.fret == 0) {
                point.x = CGRectGetWidth(neckFrame) - (topWidth / 2.0f);
            } else {
                point.x = CGRectGetWidth(neckFrame) - topWidth - (fretWidth * ((CGFloat)(note.fret - 1) + 0.5f));
            }
            point.y = CGRectGetMinY(neckFrame) + (stringHeight * ((CGFloat)note.string + 0.5f));
            
            CGContextSaveGState(context);
            
            CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(point.x - radius,
                                                           point.y - radius,
                                                           radius * 2.0f,
                                                           radius * 2.0f));
            
            CGContextRestoreGState(context);
        }];
    }
}


#pragma mark -

- (void)playChord:(NSString*)chord {
    __block BOOL hasTouches = NO;
    [_touchedNotes enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSMutableSet *notes, BOOL *stop) {
        if (notes.count > 0) {
            hasTouches = YES;
            *stop = YES;
        }
    }];
    
    if (hasTouches) return;
    
    NSArray *frets = nil;
    
    if (0) {
    } else if ([chord isEqualToString:@"A"]) {
        frets = @[@(0), @(0), @(2), @(2), @(2), @(0)];
    } else if ([chord isEqualToString:@"Am"]) {
        frets = @[@(0), @(0), @(2), @(2), @(1), @(0)];
    } else if ([chord isEqualToString:@"B"]) {
        frets = @[@(0), @(1), @(3), @(3), @(3), @(1)];
    } else if ([chord isEqualToString:@"C"]) {
        frets = @[@(3), @(3), @(2), @(0), @(1), @(0)];
    } else if ([chord isEqualToString:@"D"]) {
        frets = @[@(0), @(0), @(0), @(2), @(3), @(2)];
    } else if ([chord isEqualToString:@"E"]) {
        frets = @[@(0), @(2), @(2), @(1), @(0), @(0)];
    } else if ([chord isEqualToString:@"F"]) {
        frets = @[@(0), @(0), @(3), @(2), @(1), @(1)];
    } else if ([chord isEqualToString:@"G"]) {
        frets = @[@(3), @(2), @(0), @(0), @(0), @(3)];
    }
    
    if (frets) {
        [frets enumerateObjectsUsingBlock:^(NSNumber *fret, NSUInteger idx, BOOL *stop) {
            _stickyNotes[@(idx)] = [[Note alloc] initWithFret:[fret integerValue] onString:idx];
        }];
        [self setNeedsDisplay];
    }
}


#pragma mark -

- (Note*)noteAtPoint:(CGPoint)point {
    const CGRect bounds = self.bounds;
    
    const CGFloat neckHeight = CGRectGetHeight(bounds) * kNeckHeightRatio;
    const CGFloat neckYOffset = (CGRectGetHeight(bounds) - neckHeight) / 2.0f;
    const CGRect neckFrame = CGRectMake(0.0f, neckYOffset, CGRectGetWidth(bounds), neckHeight);
    
    if (CGRectContainsPoint(neckFrame, point)) {
        const CGFloat fretWidth = CGRectGetHeight(neckFrame) * kFretAspectRatio;
        const CGFloat topWidth = fretWidth / 2.0f;
        const CGFloat stringHeight = CGRectGetHeight(neckFrame) / 6.0f;
        
        point = CGPointMake(point.x - CGRectGetMinX(neckFrame), point.y - CGRectGetMinY(neckFrame));
        
        NSInteger fret = 0;
        if (point.x < CGRectGetWidth(bounds) - topWidth) {
            fret = 1 + (NSInteger)floorf((CGRectGetWidth(bounds) - topWidth - point.x) / fretWidth);
        }
        
        NSInteger string = (NSInteger)floorf(point.y / stringHeight);
        string = MIN(string, 5);
        string = MAX(string, 0);
        
        Note *note = [[Note alloc] initWithFret:fret onString:string];
        return note;
    }
    
    return nil;
}

- (Note*)notePlayingForString:(NSInteger)string {
    __block Note *playingNote = _stickyNotes[@(string)];
    
    [(NSSet*)_touchedNotes[@(string)] enumerateObjectsUsingBlock:^(Note *note, BOOL *stop) {
        if (note.fret > playingNote.fret) {
            playingNote = note;
        }
    }];
    
    if (!playingNote) {
        playingNote = [[Note alloc] initWithFret:0 onString:string];
    }
    
    return playingNote;
}

- (void)touchNote:(Note*)note {
    if (!note) return;
    
    [(NSMutableSet*)_touchedNotes[@(note.string)] addObject:note];
    [self stopNoteOnString:note.string];
}

- (void)untouchNote:(Note*)note {
    if (!note) return;
    
    [(NSMutableSet*)_touchedNotes[@(note.string)] removeObject:note];
}

- (void)selectNote:(Note*)note {
    __block Note *maxFretNote = nil;
    NSMutableSet *touchedNotesForString = _touchedNotes[@(note.string)];
    [touchedNotesForString enumerateObjectsUsingBlock:^(Note *n, BOOL *stop) {
        if (!maxFretNote || n.fret > maxFretNote.fret) {
            maxFretNote = n;
        }
    }];
    
    if (!maxFretNote || ![maxFretNote isEqual:note]) {
        _stickyNotes[@(note.string)] = note;
    } else {
        [_stickyNotes removeObjectForKey:@(note.string)];
    }
}

- (void)pluckString:(NSInteger)string {
    [self stopNoteOnString:string];
    
    Note *note = [self notePlayingForString:string];
    _playingNotes[@(string)] = note;
    
    if ([_delegate respondsToSelector:@selector(guitarNeck:didStartNote:)]) {
        [_delegate guitarNeck:self didStartNote:note.noteNumber];
    }
    
    NSTimer *stopTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(stopStringTimerFired:) userInfo:@{@"string":@(string)} repeats:NO];
    _playingNotesStopTimers[@(string)] = stopTimer;
}

- (void)stopStringTimerFired:(NSTimer*)timer {
    NSInteger string = [(NSNumber*)[timer.userInfo objectForKey:@"string"] integerValue];
    [self stopNoteOnString:string];
}

- (void)stopNoteOnString:(NSInteger)string {
    Note *note = _playingNotes[@(string)];
    if (note) {
        if ([_delegate respondsToSelector:@selector(guitarNeck:didStopNote:)]) {
            [_delegate guitarNeck:self didStopNote:note.noteNumber];
        }
        [_playingNotes removeObjectForKey:@(string)];
    }
    
    NSTimer *timer = _playingNotesStopTimers[@(string)];
    if (timer) {
        [timer invalidate];
        [_playingNotesStopTimers removeObjectForKey:@(string)];
    }
}


#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [touches enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
        CGPoint point = [touch locationInView:self];
        
        Note *note = [self noteAtPoint:point];
        [self touchNote:note];
    }];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [touches enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
        CGPoint point = [touch locationInView:self];
        CGPoint oldPoint = [touch previousLocationInView:self];
        
        Note *note = [self noteAtPoint:point];
        Note *oldNote = [self noteAtPoint:oldPoint];
        
        if (![note isEqual:oldNote]) {
            [self untouchNote:oldNote];
            [self touchNote:note];
        }
        
        if ((!note && oldNote) || (note && oldNote && oldNote.string != note.string)) {
            [self pluckString:oldNote.string];
            [_strummingTouches addObject:touch];
        }
    }];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [touches enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
        CGPoint point = [touch locationInView:self];
        
        Note *note = [self noteAtPoint:point];
        if (note) {
            [self untouchNote:note];
            
            if (![_strummingTouches containsObject:touch]) {
                [self selectNote:note];
            }
            [_strummingTouches removeObject:touch];
        }
    }];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [touches enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
        CGPoint point = [touch locationInView:self];
        
        Note *note = [self noteAtPoint:point];
        [self untouchNote:note];
        
        [_strummingTouches removeObject:touch];
    }];
    [self setNeedsDisplay];
}

@end
