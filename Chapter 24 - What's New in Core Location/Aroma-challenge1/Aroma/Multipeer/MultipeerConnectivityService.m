//
//  MultipeerConnectivityService.m
//  Aroma
//
//  Created by Chris Wagner on 8/5/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "MultipeerConnectivityService.h"

@import MultipeerConnectivity;

@interface MultipeerConnectivityService () <MCSessionDelegate, MCBrowserViewControllerDelegate>

@end

@import MultipeerConnectivity;

@implementation MultipeerConnectivityService {
    MCAdvertiserAssistant *_advertiserAssistant;
    MCBrowserViewController *_browserViewController;
    MCSession *_session;
}

+ (MultipeerConnectivityService *)sharedService {
    static dispatch_once_t onceToken;
    static MultipeerConnectivityService *sharedService;
    dispatch_once(&onceToken, ^{
        sharedService = [[self alloc] init];
    });
    
    return sharedService;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)advertiseWithName:(NSString *)name {
    MCPeerID *peerId = [[MCPeerID alloc] initWithDisplayName:name];
    _session = [[MCSession alloc] initWithPeer:peerId];
    _session.delegate = self;
    _advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:@"rzw-waitlist"
                                                                discoveryInfo:nil
                                                                      session:_session];
    [_advertiserAssistant start];
}

- (void)presentBrowserFromViewController:(UIViewController *)presentingViewController peerName:(NSString *)peerName {
    MCPeerID *peerId = [[MCPeerID alloc] initWithDisplayName:peerName];
    _session = [[MCSession alloc] initWithPeer:peerId];
    _browserViewController = [[MCBrowserViewController alloc] initWithServiceType:@"rzw-waitlist" session:_session];
    _browserViewController.delegate = self;
    [presentingViewController presentViewController:_browserViewController animated:YES completion:nil];
}

- (void)sendMessage:(NSData *)data error:(NSError **)error {
    [_session sendData:data toPeers:[_session connectedPeers] withMode:MCSessionSendDataReliable error:error];
}

#pragma mark - MCSessionDelegate Methods

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    if ([_delegate respondsToSelector:@selector(didChangeState:forPeer:)]) {
        [_delegate didChangeState:state forPeer:peerID];
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    if ([_delegate respondsToSelector:@selector(didReceiveData:fromPeer:)]) {
        [_delegate didReceiveData:data fromPeer:peerID];
    }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    // streaming not implemented as it will not be used for this app
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    // resources not implemented as it will not be used for this app
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    // resources not implemented as it will not be used for this app
}

#pragma mark - MCBrowserViewControllerDelegate Methods

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    if ([_delegate respondsToSelector:@selector(browserViewControllerDidFinish:)]) {
        [_delegate browserViewControllerDidFinish:browserViewController];
    }
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    if ([_delegate respondsToSelector:@selector(browserViewControllerWasCancelled:)]) {
        [_delegate browserViewControllerWasCancelled:browserViewController];
    }
}


@end
