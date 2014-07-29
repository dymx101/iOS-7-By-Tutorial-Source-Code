//
//  PushCell.m
//  Pushitup
//
//  Created by Cesare Rocchi on 7/9/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import "PushCell.h"
#import <QuartzCore/QuartzCore.h>


@implementation PushCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)setSelected:(BOOL)selected {

    [super setSelected:selected];
    
    if (selected) {
        
        self.contentView.layer.borderColor = [UIColor blueColor].CGColor;
        self.contentView.layer.borderWidth = 1;
        
    } else {
        
        self.contentView.layer.borderWidth = 0;
    
    }
    
}

@end
