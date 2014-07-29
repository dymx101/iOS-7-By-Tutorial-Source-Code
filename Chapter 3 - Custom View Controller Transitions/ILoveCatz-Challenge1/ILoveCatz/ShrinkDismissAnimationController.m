//
//  ShrinkDismissAnimationController.m
//  ILoveCatz
//
//  Created by Colin Eberhardt on 23/08/2013.
//  Copyright (c) 2013 com.razeware. All rights reserved.
//

#import "ShrinkDismissAnimationController.h"

@implementation ShrinkDismissAnimationController

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    // 1. obtain state from the context
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
    
    // 2. obtain the container view
    UIView *containerView = [transitionContext containerView];
    
    // 3. set initial state
    toViewController.view.frame = finalFrame;
    toViewController.view.alpha = 0.5;
    
    // 4. add the view
    [containerView addSubview:toViewController.view];
    [containerView sendSubviewToBack:toViewController.view];

    // 1. Determine the intermediate and final frame for the from view
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect shrunkenFrame = CGRectInset(fromViewController.view.frame, fromViewController.view.frame.size.width/4, fromViewController.view.frame.size.height/4);
    CGRect fromFinalFrame = CGRectOffset(shrunkenFrame, 0, screenBounds.size.height);

    NSTimeInterval duration = [self transitionDuration:transitionContext];

    // animate with keyframes
    [UIView animateKeyframesWithDuration:duration
               delay:0.0
             options:UIViewKeyframeAnimationOptionCalculationModeCubic
          animations:^{
            // 2a. keyframe one
            [UIView addKeyframeWithRelativeStartTime:0.0
                                    relativeDuration:0.5
                                          animations:^{
                                              fromViewController.view.transform = CGAffineTransformMakeScale(0.5, 0.5);
                toViewController.view.alpha = 0.5;
            }];
            // 2b. keyframe two
            [UIView addKeyframeWithRelativeStartTime:0.5
                                    relativeDuration:0.5
                                          animations:^{
                fromViewController.view.frame = fromFinalFrame;
                toViewController.view.alpha = 1.0;
            }];
          }
          completion:^(BOOL finished) {
              // 3. inform the context of completion
              [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
          }];

}

@end
