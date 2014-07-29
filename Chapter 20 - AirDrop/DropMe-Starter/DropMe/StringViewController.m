//
//  StringViewController.m
//  DropMe
//
//  Created by Soheil Azarpour on 6/25/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "StringViewController.h"

@interface StringViewController () <UITextViewDelegate>
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *textViewBottomSpacing;
@end

@implementation StringViewController

#pragma mark
#pragma mark - View life cycle

- (void)viewDidLoad
{
    // Customize appearance.
    UIColor *backgroundBlueTint = RGBColor(35.0, 141.0, 207.0);
    self.textView.tintColor = backgroundBlueTint;
    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Register for keyboard notifications to adjust the frame of the text view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidAppearWithNotification:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappearWithNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // If keyboard is up, dismiss it.
    [self doneButtonTapped:nil];
    
    // Clean up.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

#pragma mark
#pragma mark - UITextView delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // Display the 'Done' button.
    [self showDoneButton];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    // Hide the 'Done' button.
    [self hideDoneButton];
}

#pragma mark
#pragma mark - IBActions

- (IBAction)doneButtonTapped:(id)sender
{
    [self.textView resignFirstResponder];
}

#pragma mark
#pragma mark - Helper methods

/*
 * Add a UIBarButton 'Done' to end editing text view.
 */
- (void)showDoneButton
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
    [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
}

/*
 * Remove the UIBarbutton 'Done' as it is not needed anymore.
 * It is added when editing again.
 */
- (void)hideDoneButton
{
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

/*
 * Gets called when UIKeyboardDidShowNotification is sent.
 * Update text view frame.
 */
- (void)keyboardDidAppearWithNotification:(NSNotification *)notification
{
    // Get the frame of the keybord and convert it to the coordinate of the view.
    NSValue *value = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect adjustedFrame = [self.view.window convertRect:value.CGRectValue toView:self.view];
    
    // Get the difference. This is the amount text view must be shrunk in height.
    CGFloat delta = self.textView.bounds.size.height - adjustedFrame.origin.y;
    
    self.textViewBottomSpacing.constant = -delta;
    
    [self.view layoutIfNeeded];
}

/*
 * Gets called when UIKeyboardWillHideNotification is sent.
 * Update text view frame.
 */
- (void)keyboardWillDisappearWithNotification:(NSNotification *)notification
{
    self.textViewBottomSpacing.constant = 0.0;
    [self.view layoutIfNeeded];
}

@end
