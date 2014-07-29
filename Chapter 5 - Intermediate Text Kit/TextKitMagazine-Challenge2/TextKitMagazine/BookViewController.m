//
//  DetailViewController.m
//  TextKitMagazine
//
//  Created by Colin Eberhardt on 02/07/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "BookViewController.h"
#import "BookView.h"
#import "AppDelegate.h"
#import "BookViewDelegate.h"

@interface BookViewController () <BookViewDelegate, UIPopoverControllerDelegate>


@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation BookViewController
{
    BookView* _bookView;
    UIPopoverController* _popover;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.87f alpha:1.0f];

    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
    _bookView = [[BookView alloc] initWithFrame:self.view.bounds];
    _bookView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _bookView.bookMarkup = appDelegate.bookMarkup;
    _bookView.bookViewDelegate = self;
    
    [self.view addSubview:_bookView];

    // handle content size change notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    // tell the app delegate to re-load the markup. This will cause
    // it to create new text attributes based on the current font preferences
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate parseBookMarkdown];

    // provide the updated markup to the book view and re-draw
    _bookView.bookMarkup = appDelegate.bookMarkup;
    [_bookView buildFrames];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [_bookView removeWordHighlight];
}


- (void)bookView:(BookView *)bookView didHighlightWord:(NSString *)word inRect:(CGRect)rect {
    
    // use the built-in dictionary
    UIReferenceLibraryViewController* dictionaryVC = [[UIReferenceLibraryViewController alloc] initWithTerm: word];
    _popover.contentViewController = dictionaryVC;
    
    // Create a popover
    _popover = [[UIPopoverController alloc] initWithContentViewController:dictionaryVC];
    _popover.delegate = self;
    
    // show the popover
    [_popover presentPopoverFromRect:rect
                              inView:_bookView
            permittedArrowDirections:UIPopoverArrowDirectionAny
                            animated:YES];
    
}


- (void)viewDidLayoutSubviews {
    [_bookView buildFrames];
}

- (void)navigateToCharacterLocation:(NSUInteger)location {
    [self.masterPopoverController dismissPopoverAnimated:YES];
    [_bookView navigateToCharacterLocation:location];
}

#pragma  - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = @"Chapters";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
