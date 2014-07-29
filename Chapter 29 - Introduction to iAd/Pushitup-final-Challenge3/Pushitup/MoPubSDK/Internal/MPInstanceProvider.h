//
//  MPInstanceProvider.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPGlobal.h"


@class MPAdConfiguration;

// Fetching Ads
@class MPAdServerCommunicator;
@protocol MPAdServerCommunicatorDelegate;

// Banners
@class MPBannerAdManager;
@protocol MPBannerAdManagerDelegate;
@class MPBaseBannerAdapter;
@protocol MPBannerAdapterDelegate;
@class MPBannerCustomEvent;
@protocol MPBannerCustomEventDelegate;

// Interstitials
@class MPInterstitialAdManager;
@protocol MPInterstitialAdManagerDelegate;
@class MPBaseInterstitialAdapter;
@protocol MPInterstitialAdapterDelegate;
@class MPInterstitialCustomEvent;
@protocol MPInterstitialCustomEventDelegate;
@class MPHTMLInterstitialViewController;
@class MPMRAIDInterstitialViewController;
@protocol MPInterstitialViewControllerDelegate;

// HTML Ads
@class MPAdWebView;
@class MPAdWebViewAgent;
@protocol MPAdWebViewAgentDelegate;

// URL Handling
@class MPURLResolver;
@class MPAdDestinationDisplayAgent;
@protocol MPAdDestinationDisplayAgentDelegate;

// Utilities
@class MPAnalyticsTracker;
@class MPReachability;
@class MPTimer;
@class CTCarrier;


typedef id(^MPSingletonProviderBlock)();

@interface MPInstanceProvider : NSObject

+ (MPInstanceProvider *)sharedProvider;
- (id)singletonForClass:(Class)klass provider:(MPSingletonProviderBlock)provider;

#pragma mark - Fetching Ads
- (NSMutableURLRequest *)buildConfiguredURLRequestWithURL:(NSURL *)URL;
- (MPAdServerCommunicator *)buildMPAdServerCommunicatorWithDelegate:(id<MPAdServerCommunicatorDelegate>)delegate;

#pragma mark - Banners
- (MPBannerAdManager *)buildMPBannerAdManagerWithDelegate:(id<MPBannerAdManagerDelegate>)delegate;
- (MPBaseBannerAdapter *)buildBannerAdapterForConfiguration:(MPAdConfiguration *)configuration
                                                   delegate:(id<MPBannerAdapterDelegate>)delegate;
- (MPBannerCustomEvent *)buildBannerCustomEventFromCustomClass:(Class)customClass
                                                      delegate:(id<MPBannerCustomEventDelegate>)delegate;

#pragma mark - Interstitials
- (MPInterstitialAdManager *)buildMPInterstitialAdManagerWithDelegate:(id<MPInterstitialAdManagerDelegate>)delegate;
- (MPBaseInterstitialAdapter *)buildInterstitialAdapterForConfiguration:(MPAdConfiguration *)configuration
                                                               delegate:(id<MPInterstitialAdapterDelegate>)delegate;
- (MPInterstitialCustomEvent *)buildInterstitialCustomEventFromCustomClass:(Class)customClass
                                                                  delegate:(id<MPInterstitialCustomEventDelegate>)delegate;
- (MPHTMLInterstitialViewController *)buildMPHTMLInterstitialViewControllerWithDelegate:(id<MPInterstitialViewControllerDelegate>)delegate
                                                                        orientationType:(MPInterstitialOrientationType)type
                                                                   customMethodDelegate:(id)customMethodDelegate;
- (MPMRAIDInterstitialViewController *)buildMPMRAIDInterstitialViewControllerWithDelegate:(id<MPInterstitialViewControllerDelegate>)delegate
                                                                            configuration:(MPAdConfiguration *)configuration;

#pragma mark - HTML Ads
- (MPAdWebView *)buildMPAdWebViewWithFrame:(CGRect)frame
                                  delegate:(id<UIWebViewDelegate>)delegate;
- (MPAdWebViewAgent *)buildMPAdWebViewAgentWithAdWebViewFrame:(CGRect)frame
                                                     delegate:(id<MPAdWebViewAgentDelegate>)delegate
                                         customMethodDelegate:(id)customMethodDelegate;

#pragma mark - URL Handling
- (MPURLResolver *)buildMPURLResolver;
- (MPAdDestinationDisplayAgent *)buildMPAdDestinationDisplayAgentWithDelegate:(id<MPAdDestinationDisplayAgentDelegate>)delegate;

#pragma mark - Utilities
- (MPAnalyticsTracker *)sharedMPAnalyticsTracker;
- (MPReachability *)sharedMPReachability;
- (CTCarrier *)buildCTCarrier;
- (MPTimer *)buildMPTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)selector repeats:(BOOL)repeats;

@end
