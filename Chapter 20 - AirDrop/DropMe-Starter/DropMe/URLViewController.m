//
//  URLViewController.m
//  DropMe
//
//  Created by Soheil Azarpour on 6/25/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "URLViewController.h"

@interface URLViewController () <UITextFieldDelegate, UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIView *activityView;
@end

@implementation URLViewController

#pragma mark
#pragma mark - View life cycle

- (void)viewDidLoad
{
    // Customize appearance.
    UIColor *backgroundBlueTint = RGBColor(35.0, 141.0, 207.0);
    self.textField.tintColor = backgroundBlueTint;
    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadURL:[NSURL URLWithString:self.textField.text]];
    
    [super viewDidAppear:animated];
}

#pragma mark
#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self loadURL:[NSURL URLWithString:textField.text]];
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark
#pragma mark - Helper methods

/*
 * A convenient method to load a given URL in the web view
 * and also set the object to share.
 */
- (void)loadURL:(NSURL *)URL
{
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:request];
}

/*
 * Display the activity view. It is a UIView with an activity
 * indicator as a subview. Also turn on the network activity
 * indicator in the status bar.
 */
- (void)displayActivityView
{
    [UIView animateWithDuration:0.30 animations:^{
        
        self.activityView.alpha = 0.5;
        
    } completion:^(BOOL finished) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
    }];
}

/*
 * Hide the activity view and turn off the network activity
 * indicator in the status bar.
 */
- (void)hideActivityView
{
    [UIView animateWithDuration:0.30 animations:^{
        
        self.activityView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    }];
}

#pragma mark
#pragma mark - UIWebView delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self displayActivityView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideActivityView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    [alert show];
    [self hideActivityView];
}

@end
