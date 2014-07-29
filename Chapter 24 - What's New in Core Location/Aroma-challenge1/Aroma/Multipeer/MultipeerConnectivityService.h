//
//  MultipeerConnectivityService.h
//  Aroma
//
//  Created by Chris Wagner on 8/5/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MultipeerConnectivity;

@protocol MultipeerConnecivityServiceDelegate <NSObject>

@optional
- (void)didChangeState:(MCSessionState)state forPeer:(MCPeerID *)peerId;
- (void)didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerId;

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController;
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController;

@end

@interface MultipeerConnectivityService : NSObject

@property (weak, nonatomic) id<MultipeerConnecivityServiceDelegate> delegate;

+ (MultipeerConnectivityService *)sharedService;

- (void)advertiseWithName:(NSString *)name;
- (void)presentBrowserFromViewController:(UIViewController *)presentingViewController peerName:(NSString *)peerName;
- (void)sendMessage:(NSData *)data error:(NSError **)error;

@end
