//
//  PinchInteractionController.h
//  ILoveCatz
//
//  Created by Colin Eberhardt on 27/08/2013.
//  Copyright (c) 2013 com.razeware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PinchInteractionController : UIPercentDrivenInteractiveTransition


- (void)wireToViewController:(UIViewController*)viewController;

@property (nonatomic, assign) BOOL interactionInProgress;

@end
