//
//  CETimeView.h
//  TextKitNotepad
//
//  Created by Colin Eberhardt on 20/06/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

// a view that renders the time of a note within a circle
@interface TimeIndicatorView : UIView

- (id) init:(NSDate*)date;

// updates the size of this view to comfortably hold the current text. After this
// method is invoked the view will be located at the origin.
- (void) updateSize;

- (UIBezierPath *)curvePathWithOrigin:(CGPoint)origin;

@end
