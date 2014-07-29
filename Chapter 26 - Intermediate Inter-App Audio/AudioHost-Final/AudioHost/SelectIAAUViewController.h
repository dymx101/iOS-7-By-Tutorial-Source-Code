//
//  SelectIAAUViewController.h
//  iGuitar
//
//  Created by Matt Galloway on 19/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import <UIKit/UIKit.h>

@import AudioUnit.AudioComponent;

@class SelectIAAUViewController;
@class InterAppAudioUnit;

@protocol SelectIAAUViewControllerDelegate <NSObject>
- (void)selectIAAUViewController:(SelectIAAUViewController*)viewController didSelectUnit:(InterAppAudioUnit*)unit;
- (void)selectIAAUViewControllerWantsToClose:(SelectIAAUViewController*)viewController;
@end

@interface SelectIAAUViewController : UITableViewController

- (instancetype)initWithSearchDescription:(AudioComponentDescription)description;

@property (nonatomic, weak) id <SelectIAAUViewControllerDelegate> delegate;

@end
