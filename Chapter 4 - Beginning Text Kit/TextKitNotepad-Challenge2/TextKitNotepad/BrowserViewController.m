//
//  BrowserViewController.m
//  TextKitNotepad
//
//  Created by Colin Eberhardt on 26/08/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "BrowserViewController.h"

@interface BrowserViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation BrowserViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSURLRequest* request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];

}


@end
