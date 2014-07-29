//
//  SelectEffectViewController.h
//  iGuitar
//
//  Created by Matt Galloway on 19/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectEffectViewController;
@class Effect;

@protocol SelectEffectViewControllerDelegate <NSObject>
- (void)selectEffectViewController:(SelectEffectViewController*)viewController didSelectEffect:(Effect*)effect;
- (void)selectEffectViewControllerWantsToClose:(SelectEffectViewController*)viewController;
@end

@interface SelectEffectViewController : UITableViewController

@property (nonatomic, weak) id <SelectEffectViewControllerDelegate> delegate;

@end
