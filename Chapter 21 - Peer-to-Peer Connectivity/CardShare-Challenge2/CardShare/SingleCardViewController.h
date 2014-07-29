//
//  MyCardViewController.h
//  GreatExchange
//
//  Created by Christine Abernathy on 7/9/13.
//  Copyright (c) 2013 Elidora LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"

@interface SingleCardViewController : UIViewController

@property (strong, nonatomic) Card *card;
@property (assign, nonatomic) BOOL enableAddToCards;

@end
