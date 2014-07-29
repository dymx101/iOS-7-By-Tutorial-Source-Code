//
//  AttributedStringViewController.m
//  DropMe
//
//  Created by Soheil Azarpour on 6/25/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "AttributedStringViewController.h"

@interface AttributedStringViewController () <UITextViewDelegate>
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *textViewBottomSpacing;

@end

@implementation AttributedStringViewController

#pragma mark
#pragma mark - View life cycle

- (void)viewDidLoad
{
    // Customize appearance.
    UIColor *backgroundBlueTint = RGBColor(35.0, 141.0, 207.0);
    self.textView.tintColor = backgroundBlueTint;
    
    // Evaluate the text in text view with the color map and
    // add text color to it.
    self.textView.attributedText = [self evaluatedAttributedStringWithAttributedString:self.textView.attributedText];
    
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
    // Evaluate the text in text view with the color map and
    // add text color to it.
    NSAttributedString *attrStr = [self evaluatedAttributedStringWithAttributedString:textView.attributedText];
    textView.attributedText = attrStr;
    
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

#pragma mark
#pragma mark - Regex and color logic

/*
 * Use NSRegularExpression to search the input text, match any color name
 * you find, change the text color of the color name to match it and return
 * an NSAttributedString from it.
 */
- (NSAttributedString *)evaluatedAttributedStringWithAttributedString:(NSAttributedString *)attributedString
{
    NSString *pattern = @"\\b\\w+\\b";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSRange range = NSMakeRange(0, attributedString.length);
    NSArray *matches = [regex matchesInString:attributedString.string options:NSMatchingReportProgress range:range];
    NSMutableAttributedString *attrStr = attributedString.mutableCopy;
    [matches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSTextCheckingResult *match = (NSTextCheckingResult *)obj;
        NSRange matchRange = match.range;
        NSString *substring = [attrStr.string substringWithRange:matchRange];
        UIColor *textColor = [self textColorWithText:substring];
        [attrStr addAttribute:NSForegroundColorAttributeName value:textColor range:matchRange];
    }];
    
    return attrStr.copy;
}

/*
 * Return UIColor based on the name of the color.
 * If not found, returns UIColor blackColor.
 */
- (UIColor *)textColorWithText:(NSString *)text
{
    UIColor *defaultColor = [UIColor blackColor];
    NSDictionary *colorMap = @{
                               @"red": [UIColor redColor],
                               @"green": [UIColor greenColor],
                               @"yellow": [UIColor yellowColor],
                               @"blue": [UIColor blueColor],
                               @"brown": [UIColor brownColor],
                               @"orange": [UIColor orangeColor],
                               @"purple": [UIColor purpleColor]
                               };
    UIColor *resultColor = colorMap[text.lowercaseString];
    return (resultColor ? resultColor : defaultColor);
}

@end
