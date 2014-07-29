//
//  MPPrivateInterstitialcustomEventDelegate.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPInterstitialCustomEventDelegate.h"

@class MPAdConfiguration;

@protocol MPPrivateInterstitialCustomEventDelegate <MPInterstitialCustomEventDelegate>

- (MPAdConfiguration *)configuration;
- (id)interstitialDelegate;

@end
