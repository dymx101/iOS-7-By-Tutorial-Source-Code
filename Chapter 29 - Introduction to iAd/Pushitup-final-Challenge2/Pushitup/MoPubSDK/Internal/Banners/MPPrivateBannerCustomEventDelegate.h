//
//  MPPrivateBannerCustomEventDelegate.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPBannerCustomEventDelegate.h"

@class MPAdConfiguration;

@protocol MPPrivateBannerCustomEventDelegate <MPBannerCustomEventDelegate>

- (MPAdConfiguration *)configuration;
- (id)bannerDelegate;

@end
