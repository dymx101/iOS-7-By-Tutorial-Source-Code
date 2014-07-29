//
//  CENoteEditorControllerViewController.m
//  TextKitNotepad
//
//  Created by Colin Eberhardt on 19/06/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "NoteEditorViewController.h"
#import "Note.h"
#import "TimeIndicatorView.h"
#import "SyntaxHighlightTextStorage.h"
#import "BrowserViewController.h"

@interface NoteEditorViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end

@implementation NoteEditorViewController
{
    TimeIndicatorView* _timeView;
    SyntaxHighlightTextStorage* _textStorage;
    UITextView* _textView;
    CGRect _textViewFrame;
    NSURL* _tappedUrl;
}

- (void)createTextView
{
    // 1. Create the text storage that backs the editor
    NSDictionary* attrs = @{NSFontAttributeName:
                                [UIFont preferredFontForTextStyle:UIFontTextStyleBody]};
    NSAttributedString* attrString = [[NSAttributedString alloc] initWithString:_note.contents
                                                                     attributes:attrs];
    _textStorage = [SyntaxHighlightTextStorage new];
    [_textStorage appendAttributedString:attrString];
    
    CGRect newTextViewRect = self.view.bounds;
    
    // 2. Create the layout manager
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    // 3. Create a text container
    CGSize containerSize = CGSizeMake(newTextViewRect.size.width, CGFLOAT_MAX);
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:containerSize];
    container.widthTracksTextView = YES;
    [layoutManager addTextContainer:container];
    [_textStorage addLayoutManager:layoutManager];
    
    // 4. Create a UITextView
    _textView = [[UITextView alloc] initWithFrame:newTextViewRect
                                    textContainer:container];
    _textView.delegate = self;
    [self.view addSubview:_textView];
    
    // ensure that the text view is not editable initially
    _textView.editable = NO;
    _textView.dataDetectorTypes = UIDataDetectorTypeLink;
}

- (IBAction)editButtonTapped:(id)sender {
    if (_textView.editable) {
        self.editButton.title = @"Edit";
        _textView.editable = NO;
        [_textView resignFirstResponder];
    } else {
        self.editButton.title = @"Done";
        _textView.editable = YES;
        [_textView becomeFirstResponder];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createTextView];
    _textViewFrame = self.view.bounds;
    
    // handle content size change notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    

    _timeView = [[TimeIndicatorView alloc] init:self.note.timestamp];
    [self.view addSubview:_timeView];

}

- (void)viewDidLayoutSubviews {
    [self updateTimeIndicatorFrame];
    _textView.frame = _textViewFrame;
}

- (void) updateTimeIndicatorFrame {
    [_timeView updateSize];
    _timeView.frame = CGRectOffset(_timeView.frame,
          self.view.frame.size.width - _timeView.frame.size.width, 0.0);
    
    // add an exclusion path for the time display
    UIBezierPath* exclusionPath = [_timeView curvePathWithOrigin:_timeView.center];
    _textView.textContainer.exclusionPaths  = @[exclusionPath];
}

- (void)preferredContentSizeChanged:(NSNotification *)n {
    _textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [self updateTimeIndicatorFrame];
    [_textStorage update];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    _textViewFrame = self.view.bounds;
    _textViewFrame.size.height -= 216.0f;
    _textView.frame = _textViewFrame;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    // copy the updated note text to the underlying model.
    self.note.contents = textView.text;
    
    _textViewFrame = self.view.bounds;
    _textView.frame = _textViewFrame;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    // when a link is tapped - record the URL and seqgue
    _tappedUrl = URL;
    [self performSegueWithIdentifier:@"showBrowser" sender:self];
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showBrowser"]) {
        // when the browser view controller loads, set the URL
        BrowserViewController* browserVC = (BrowserViewController*)segue.destinationViewController;
        browserVC.url = _tappedUrl;
    }

}


@end
