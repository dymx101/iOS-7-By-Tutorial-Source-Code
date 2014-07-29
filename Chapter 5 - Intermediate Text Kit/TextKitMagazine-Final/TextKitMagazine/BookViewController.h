//
//  DetailViewController.h
//  TextKitMagazine
//
//  Created by Colin Eberhardt on 02/07/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookViewController : UIViewController <UISplitViewControllerDelegate>

- (void)navigateToCharacterLocation:(NSUInteger)location;

@end
