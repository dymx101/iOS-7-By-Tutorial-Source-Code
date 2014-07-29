//
//  PinchInteractionController.m
//  ILoveCatz
//
//  Created by Colin Eberhardt on 27/08/2013.
//  Copyright (c) 2013 com.razeware. All rights reserved.
//

#import "PinchInteractionController.h"

@implementation PinchInteractionController {
    BOOL _shouldCompleteTransition;
    UIViewController *_viewController;
    CGFloat _startScale;
}

- (void)wireToViewController:(UIViewController *)viewController {
    _viewController = viewController;
    [self prepareGestureRecognizerInView:viewController.view];
}


- (void)prepareGestureRecognizerInView:(UIView*)view {
    UIPinchGestureRecognizer *gesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [view addGestureRecognizer:gesture];
}

- (CGFloat)completionSpeed
{
    return 1 - self.percentComplete;
}

- (void)handlePinch:(UIPinchGestureRecognizer*)gestureRecognizer {
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            _startScale = gestureRecognizer.scale;
            // 1. Start an interactive transition!
            self.interactionInProgress = YES;
            [_viewController dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged: {
            // 2. compute the current position
            CGFloat fraction = 1.0 - gestureRecognizer.scale / _startScale;
            // 3. should we complete?
            _shouldCompleteTransition = (fraction > 0.5);
            // 4. update the animation controller
            [self updateInteractiveTransition:fraction];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            // 5. finish or cancel
            self.interactionInProgress = NO;
            if (!_shouldCompleteTransition || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
                [self cancelInteractiveTransition];
            }
            else {
                [self finishInteractiveTransition];
            }
            break;
        default:
            break;
    }
}

@end
