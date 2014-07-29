//
//  BaseViewController.m
//  DropMe
//
//  Created by Soheil Azarpour on 6/25/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "BaseViewController.h"
@import AudioToolbox;

@interface BaseViewController ()
@end

@implementation BaseViewController

- (void)viewDidLoad
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropIcon"]];
    [super viewDidLoad];
}

#pragma mark
#pragma mark - Custom getters and setters

- (void)setObjectsToShare:(NSArray *)objectsToShare
{
    _objectsToShare = [objectsToShare copy];
    
    /*
     * If there is an object in the array to share, display the action button;
     * otherwise, hide the action button.
     */
    if (objectsToShare.count)
        [self displayActionButton];
    else
        [self hideActionButton];
}

#pragma mark
#pragma mark - IBActions

- (IBAction)actionButtonTapped:(id)sender
{
    [self presentActivityViewControllerWithObjects:self.objectsToShare];
}

#pragma mark
#pragma mark - Helper methods

/*
 * Create a UIBarButton item with UIBarButtonSystemItemAction and display
 * it in the navigation bar.
 */
- (void)displayActionButton
{
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                  target:self
                                                                                  action:@selector(actionButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:actionButton animated:YES];
}

/*
 * Remove the action bar button item.
 */
- (void)hideActionButton
{
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

/*
 * Configure and present an instance of UIActivityViewController for AirDrop only.
 */
- (void)presentActivityViewControllerWithObjects:(NSArray *)objects
{
    // Create an instance of UIActivityViewController with the object.
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objects applicationActivities:nil];
    
    // Exclude all activities except AirDrop.
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage, UIActivityTypeMail,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;
    
    // Present it.
    [self presentViewController:controller animated:YES completion:nil];
}

@end
