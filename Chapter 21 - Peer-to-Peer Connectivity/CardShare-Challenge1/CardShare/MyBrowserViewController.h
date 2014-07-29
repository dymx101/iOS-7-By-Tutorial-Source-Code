//
//  MyBrowserViewController.h
//  GreatExchange
//
//  Created by Christine Abernathy on 7/1/13.
//  Copyright (c) 2013 Elidora LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol MyBrowserViewControllerDelegate;

@interface MyBrowserViewController : UIViewController

@property (nonatomic, weak, readwrite) id<MyBrowserViewControllerDelegate> delegate;
@property(nonatomic, assign) NSUInteger maximumNumberOfPeers;
@property(nonatomic, assign) NSUInteger minimumNumberOfPeers;

- (void)setupWithServiceType:(NSString *)serviceType session:(MCSession *)session peer:(MCPeerID *)peerId;

@end

@protocol MyBrowserViewControllerDelegate <NSObject>

@optional

- (void)myBrowserViewControllerDidFinish:(MyBrowserViewController *)browserViewController;
// Called when the user taps the Done button

- (void)myBrowserViewControllerWasCancelled:(MyBrowserViewController *)browserViewController;
// Called when the user taps the Cancel button

@end
