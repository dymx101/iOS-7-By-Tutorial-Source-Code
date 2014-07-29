//
//  MyBrowserTableViewCell.m
//  GreatExchange
//
//  Created by Christine Abernathy on 7/15/13.
//  Copyright (c) 2013 Elidora LLC. All rights reserved.
//

#import "MyBrowserTableViewCell.h"
#import "AppDelegate.h"

@implementation MyBrowserTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    self.textLabel.textColor = [(AppDelegate *)[[UIApplication sharedApplication] delegate] mainColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        self.textLabel.textColor = [(AppDelegate *)[[UIApplication sharedApplication] delegate] mainColor];
    } else {
        self.textLabel.textColor = [UIColor blackColor];
    }
}

@end
