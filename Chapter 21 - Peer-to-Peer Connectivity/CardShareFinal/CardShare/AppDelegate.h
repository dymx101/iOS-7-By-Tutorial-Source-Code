//
//  AppDelegate.h
//  GreatExchange
//
//  Created by Christine Abernathy on 6/27/13.
//  Copyright (c) 2013 Elidora LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "Card.h"

// The service type identifier
extern NSString * const kServiceType;
// The notification string to be used for data receipts
extern NSString *const DataReceivedNotification;
// The notification string to be used for peer connections
extern NSString *const PeerConnectionAcceptedNotification;
// A flag to use programmatic APIs for the discovery phase
extern BOOL const kProgrammaticDiscovery;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCPeerID *peerId;
@property (strong, nonatomic) NSMutableArray *cards;
@property (strong, nonatomic) Card *myCard;
@property (strong, nonatomic) NSMutableArray *otherCards;

- (void) sendCardToPeer;
- (void) addToOtherCardsList:(Card *)card;
- (void) removeCardFromExchangeList:(Card *)card;
- (UIColor *) mainColor;

@end
