//
//  AppDelegate.h
//  CrazyRides
//
//  Created by Marin Todorov on 6/22/13.
//  Terms apply, source code provided with "iOS7 by Tutorials"
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/* When called from a pass, persist which ride is being booked */
@property (strong, nonatomic) NSString* bookingSeatOnRide;

@end
