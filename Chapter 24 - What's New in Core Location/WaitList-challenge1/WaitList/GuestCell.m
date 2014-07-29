//
//  GuestCell.m
//  WaitList
//
//  Created by Chris Wagner on 7/24/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "GuestCell.h"
#import "Guest.h"
#import "GuestService.h"
#import "NSNumber+SpokenTime.h"
#import "UIColor+Grayscale.h"

@implementation GuestCell {
    NSTimer *_timeTilQuoteTimer;
    NSCalendar *_calendar;
    UIColor *_evenRowColor;
    UIColor *_oddRowColor;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    
    _evenRowColor = [UIColor colorWithRed:245.0/255.0 green:228.0/255.0 blue:218.0/255.0 alpha:1];
    _oddRowColor = [UIColor colorWithRed:252.0/255.0 green:237.0/255.0 blue:224.0/255.0 alpha:1];
    
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    [UIView animateWithDuration:0.3 animations:^{
        if (self.tintAdjustmentMode == UIViewTintAdjustmentModeDimmed) {
            self.contentView.backgroundColor = [self.contentView.backgroundColor grayscale];
        } else {
            self.contentView.backgroundColor = _evenRow ? _evenRowColor : _oddRowColor;
        }
    }];
}

- (void)setGuest:(Guest *)guest {
    _guest = guest;
    [self setupCell];
}

- (void)setupCell {

    _timeTilQuoteTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateTimeTilQuoteLabel) userInfo:nil repeats:YES];
    _timeTilQuoteTimer.tolerance = 5.0;
    _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    _nameLabel.text = _guest.name;
    _partySizeLabel.text = [NSString stringWithFormat:@"%d", _guest.partySize];
    _arrivalTimeLabel.text = [[[GuestService sharedInstance] arrivalDateFormatter] stringFromDate:_guest.arrivalTime];
    _quotedTimeLabel.text = [_guest.quotedTime spokenTime];
    [self updateTimeTilQuoteLabel];
    
    switch (_guest.mood) {
        case 0: // Happy
            _moodImageView.image = [[UIImage imageNamed:@"Happy"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            _moodImageView.tintColor = [UIColor colorWithRed:68./255 green:162./255 blue:78./255 alpha:1];
            break;
        case 1: // Meh
            _moodImageView.image = [[UIImage imageNamed:@"Meh"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            _moodImageView.tintColor = [UIColor colorWithRed:232./255 green:188./255 blue:37./255 alpha:1];
            break;
        case 2: // Unhappy
            _moodImageView.image = [[UIImage imageNamed:@"Unhappy"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            _moodImageView.tintColor = [UIColor colorWithRed:176./255 green:37./255 blue:33./255 alpha:1];
            break;
        default: // What?
            break;
    }
    
    if (_evenRow) {
        self.contentView.backgroundColor = _evenRowColor;
    } else {
        self.contentView.backgroundColor = _oddRowColor;
    }
}

- (void)updateTimeTilQuoteLabel {
    NSDate *quotedTimeDate = [NSDate dateWithTimeInterval:_guest.quotedTime.integerValue * 60 sinceDate:_guest.arrivalTime];
    NSDateComponents *components = [_calendar components:NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date] toDate:quotedTimeDate options:0];

    if (components.minute < 0) { // account for past times
        if (components.minute < -59) {
            _timeTilQuoteLabel.text = @"Over an hour ago";
        } else if (components.minute == -1) {
            _timeTilQuoteLabel.text = @"1 minute ago";
        } else {
            _timeTilQuoteLabel.text = [NSString stringWithFormat:@"%d minutes ago", abs(components.minute)];
        }
    } else if (components.minute == 0) { // account for now
        _timeTilQuoteLabel.text = @"Now!";
    } else { // account for future times
        if (components.minute > 59) {
            _timeTilQuoteLabel.text = @"Over an hour";
        } else if (components.minute == 1) {
            _timeTilQuoteLabel.text = [NSString stringWithFormat:@"1 minute"];
        } else {
            _timeTilQuoteLabel.text = [NSString stringWithFormat:@"%d minutes", components.minute];
        }
    }
}

@end
