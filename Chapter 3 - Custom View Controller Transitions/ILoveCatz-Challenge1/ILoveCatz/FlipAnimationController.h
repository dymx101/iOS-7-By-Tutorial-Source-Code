//
//  BLAdTransitionController.h
//  prototype
//
//  Created by César Pinto Castillo on 12/06/13.
//  Copyright (c) 2013 Blocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlipAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL reverse;

@end
