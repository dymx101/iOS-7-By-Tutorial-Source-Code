//
//  AppDelegate.m
//  GreatExchange
//
//  Created by Christine Abernathy on 6/27/13.
//  Copyright (c) 2013 Elidora LLC. All rights reserved.
//

#import "AppDelegate.h"

// Defining the constants
NSString *const kServiceType = @"rw-cardshare";
NSString *const DataReceivedNotification =
@"com.razeware.apps.CardShare:DataReceivedNotification";
NSString *const PeerConnectionAcceptedNotification =
@"com.razeware.apps.CardShare:PeerConnectionAcceptedNotification";
BOOL const kProgrammaticDiscovery = NO;

// Invitation handler definition
typedef void(^InvitationHandler)(BOOL accept, MCSession *session);

@interface AppDelegate ()
<MCSessionDelegate,
MCNearbyServiceAdvertiserDelegate,
UIAlertViewDelegate>

@property (strong, nonatomic) MCAdvertiserAssistant *advertiserAssistant;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (strong, nonatomic) InvitationHandler handler;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Set appearance info
    [[UITabBar appearance] setBarTintColor:[self mainColor]];
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
    [[UINavigationBar appearance] setBarTintColor:[self mainColor]];
    
    [[UIToolbar appearance] setBarStyle:UIBarStyleBlackOpaque];
    [[UIToolbar appearance] setBarTintColor:[self mainColor]];
    
    // Initialize properties
    self.cards = [@[] mutableCopy];
    
    // Initialize any stored data
    self.myCard = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"myCard"]) {
        NSData *myCardData = [defaults objectForKey:@"myCard"];
        self.myCard = (Card *)[NSKeyedUnarchiver unarchiveObjectWithData:myCardData];
    }
    self.otherCards = [@[] mutableCopy];
    if ([defaults objectForKey:@"otherCards"]) {
        NSData *otherCardsData = [defaults objectForKey:@"otherCards"];
        self.otherCards = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:otherCardsData];
    }
    
    // Set up a peer
    NSString *peerName =
    self.myCard.firstName ? self.myCard.firstName :
    [[UIDevice currentDevice] name];
    self.peerId = [[MCPeerID alloc] initWithDisplayName:peerName];
    
    // Set up a session
    self.session = [[MCSession alloc] initWithPeer:self.peerId
                                  securityIdentity:nil
                              encryptionPreference:MCEncryptionNone];
    // Set the session delegate
    self.session.delegate = self;
    
    // Set up an advertiser
    if (kProgrammaticDiscovery) {
        // Set it up programmatically
        self.advertiser =
        [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerId
                                          discoveryInfo:nil
                                            serviceType:kServiceType];
        self.advertiser.delegate = self;
        // Start advertising
        [self.advertiser startAdvertisingPeer];
    } else {
        // Set it up using the convenience class
        self.advertiserAssistant =
        [[MCAdvertiserAssistant alloc] initWithServiceType:kServiceType
                                             discoveryInfo:nil
                                                   session:self.session];
        // Start advertising
        [self.advertiserAssistant start];
    }
    
    return YES;
}

#pragma mark - MCNearbyServiceAdvertiserDelegate delegate methods
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
    // Save the invitation handler for later use
    self.handler = invitationHandler;
    // Show the user an alert view so they can decide to accept
    // or reject an invitation
    [[[UIAlertView alloc] initWithTitle:@"Invitation"
                                message:[NSString stringWithFormat:@"%@ wants to connect",
                                         peerID.displayName]
                               delegate:self
                      cancelButtonTitle:@"Nope"
                      otherButtonTitles:@"Sure", nil] show];
}

#pragma mark - AlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Get the user decision
    BOOL accept = (buttonIndex == alertView.cancelButtonIndex) ? NO : YES;
    
    // Call the invitation handler
    self.handler(accept, self.session);
}

#pragma mark - MCSessionDelegate delegate methods
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (state == MCSessionStateConnected && self.session) {
        // For programmatic discovery, send a notification to the custom browser
        // that an invitation was accepted.
        [[NSNotificationCenter defaultCenter]
         postNotificationName:PeerConnectionAcceptedNotification
         object:nil
         userInfo:@{
                    @"peer": peerID,
                    @"accept" : @YES
                    }];
    } else if (state == MCSessionStateNotConnected && self.session) {
        // For programmatic discovery, send a notification to the custom browser
        // that an invitation was declined.
        // Send only if the peers are not yet connected
        if (![self.session.connectedPeers containsObject:peerID]) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:PeerConnectionAcceptedNotification
             object:nil
             userInfo:@{
                        @"peer": peerID,
                        @"accept" : @NO
                        }];
        }
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    // Get the data to be stored
    Card *card = (Card *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    // Add info to the cards array
    [self.cards addObject:card];
    
    // Trigger a notification that data was received
    [[NSNotificationCenter defaultCenter] postNotificationName:DataReceivedNotification object:nil];
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
}

#pragma mark - Helper methods
- (UIColor *)mainColor
{
    return [UIColor colorWithRed:28/255.0f green:171/255.0f blue:116/255.0f alpha:1.0f];
}

-(void)sendCardToPeer
{
    // Send data to all connected peers
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.myCard];
    NSError *error;
    [self.session sendData:data
                   toPeers:[self.session connectedPeers]
                  withMode:MCSessionSendDataReliable
                     error:&error];
}

/*
 * Implement the setter for the user's card
 * so as to set the value in storage as well.
 */
- (void)setMyCard:(Card *)aCard
{
    if (aCard != _myCard) {
        _myCard = aCard;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        // Create an NSData representation
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:aCard];
        [defaults setObject:data forKey:@"myCard"];
        [defaults synchronize];
    }
}

- (void)addToOtherCardsList:(Card *)card
{
    [self.otherCards addObject:card];
    // Update stored value
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.otherCards];
    [defaults setObject:data forKey:@"otherCards"];
    [defaults synchronize];
}

- (void) removeCardFromExchangeList:(Card *)card
{
    NSMutableSet *cardsSet = [NSMutableSet setWithArray:self.cards];
    [cardsSet removeObject:card];
    self.cards = [[cardsSet allObjects] mutableCopy];
}

@end