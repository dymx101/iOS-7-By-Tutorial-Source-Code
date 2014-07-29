//
//  HeaderCell.m
//  WaitList
//
//  Created by Chris Wagner on 8/2/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "HeaderCell.h"
#import "UIColor+Grayscale.h"

@implementation HeaderCell

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    [UIView animateWithDuration:0.3 animations:^{
        if (self.tintAdjustmentMode == UIViewTintAdjustmentModeDimmed) {
            self.contentView.backgroundColor = [self.contentView.backgroundColor grayscale];
            for (UIView *view in self.contentView.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)view;
                    label.textColor = [label.textColor grayscale];
                }
            }
        } else {
            self.contentView.backgroundColor = [UIColor colorWithRed:196.0/255.0 green:63.0/255.0 blue:34.0/255.0 alpha:1];
            for (UIView *view in self.contentView.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)view;
                    label.textColor = [UIColor colorWithRed:252.0/255.0 green:234.0/255.0 blue:218.0/255.0 alpha:1];
                }
            }
        }
    }];
}

@end
