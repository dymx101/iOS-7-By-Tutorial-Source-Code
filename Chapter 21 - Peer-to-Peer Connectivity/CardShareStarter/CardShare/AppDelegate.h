//
//  AppDelegate.h
//  GreatExchange
//
//  Created by Christine Abernathy on 6/27/13.
//  Copyright (c) 2013 Elidora LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *cards;
@property (strong, nonatomic) Card *myCard;
@property (strong, nonatomic) NSMutableArray *otherCards;

- (void) addToOtherCardsList:(Card *)card;
- (void) removeCardFromExchangeList:(Card *)card;
- (UIColor *) mainColor;

@end
