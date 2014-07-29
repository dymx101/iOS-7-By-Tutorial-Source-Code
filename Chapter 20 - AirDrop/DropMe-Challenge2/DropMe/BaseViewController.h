//
//  BaseViewController.h
//  DropMe
//
//  Created by Soheil Azarpour on 6/25/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

@import UIKit;

@interface BaseViewController : UIViewController

/**
 * @property objectsToShare
 * @brief An array of objects that will be shared via AirDrop when
 * the acitivty view controller is presented.
 */
@property (nonatomic, strong) NSArray *objectsToShare;

@end
