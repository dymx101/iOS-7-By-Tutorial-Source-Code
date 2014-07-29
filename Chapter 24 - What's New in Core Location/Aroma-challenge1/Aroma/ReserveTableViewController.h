//
//  ReserveTableViewController.h
//  Aroma
//
//  Created by Chris Wagner on 8/6/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ReserveTableCompletion)(NSString *name, NSNumber *partySize);

@interface ReserveTableViewController : UIViewController

@property (copy, nonatomic) ReserveTableCompletion completion;

@end
