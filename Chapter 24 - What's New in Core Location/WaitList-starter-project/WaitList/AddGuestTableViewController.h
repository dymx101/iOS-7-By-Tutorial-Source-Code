//
//  AddGuestTableViewController.h
//  WaitList
//
//  Created by Chris Wagner on 7/24/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Guest;

@protocol AddGuestDelegate <NSObject>

- (void)guestAdded:(Guest *)guest atIndex:(NSInteger)index;

@end

@interface AddGuestTableViewController : UITableViewController

@property (weak, nonatomic) id<AddGuestDelegate> delegate;
@property (strong, nonatomic) Guest *guest;

@end
