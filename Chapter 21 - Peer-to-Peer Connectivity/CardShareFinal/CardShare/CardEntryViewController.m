//
//  MyCardEntryViewController.m
//  GreatExchange
//
//  Created by Christine Abernathy on 7/8/13.
//  Copyright (c) 2013 Elidora LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "CardEntryViewController.h"
#import "UIImage+Resize.h"
#import "Card.h"

@interface CardEntryViewController ()
<UIImagePickerControllerDelegate,
UIActionSheetDelegate,
UIToolbarDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *companyTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *websiteTextField;
@property (weak, nonatomic) IBOutlet UIImageView *cardImageView;

@end

@implementation CardEntryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Set the toolbar delegate to be able
    // to position it to the top of the view.
    self.toolbar.delegate = self;
    
    // Get the current card values
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (nil != delegate.myCard) {
        self.cardImageView.image = delegate.myCard.image;
        self.firstNameTextField.text = delegate.myCard.firstName;
        self.lastNameTextField.text = delegate.myCard.lastName;
        self.companyTextField.text = delegate.myCard.company;
        self.emailTextField.text = delegate.myCard.email;
        self.phoneTextField.text = delegate.myCard.phone;
        self.websiteTextField.text = delegate.myCard.website;
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Action methods
- (IBAction)cancelPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)savePressed:(id)sender {
    // Validate minimum data: first name and photo
    NSString *errorMessage = @"Please ";
    BOOL displayError = NO;
    if ([self.firstNameTextField.text isEqualToString:@""]) {
        displayError = YES;
        errorMessage = [errorMessage stringByAppendingString:@"enter your first name"];
    }
    if (nil == self.cardImageView.image) {
        if (displayError) {
            errorMessage = [errorMessage stringByAppendingString:@" and "];
        }
        displayError = YES;
        errorMessage = [errorMessage stringByAppendingString:@"add a photo"];
    }
    errorMessage = [errorMessage stringByAppendingString:@"."];
    if (displayError) {
        [self showMessage:errorMessage];
        return;
    }
    
    // Set the user's card info
    Card *card = [[Card alloc] init];
    card.firstName = self.firstNameTextField.text;
    card.lastName = self.lastNameTextField.text;
    card.company = self.companyTextField.text;
    card.email = self.emailTextField.text;
    card.phone = self.phoneTextField.text;
    card.website = self.websiteTextField.text;
    card.image = self.cardImageView.image;
    
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [delegate setMyCard:card];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIToolbarDelegate methods
- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
    
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    // Set the source type of the imagePicker to the users selection
    if (buttonIndex == 0) {
        [self showImagePickerController:UIImagePickerControllerSourceTypeCamera];
    } else if (buttonIndex == 1) {
        [self showImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // From Ray Wenderlich tutorial on how to make an Instagram app
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // Resize the image from the camera
	UIImage *scaledImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(self.cardImageView.frame.size.width, self.cardImageView.frame.size.height) interpolationQuality:kCGInterpolationHigh];
    // Crop the image to a square
    UIImage *croppedImage = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -self.cardImageView.frame.size.width)/2, (scaledImage.size.height - self.cardImageView.frame.size.height)/2, self.cardImageView.frame.size.width, self.cardImageView.frame.size.height)];
    
    self.cardImageView.image = croppedImage;
    
    // Dismiss the image picker
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper methods
- (void)addPhotoPressed {
    // If running in a simulator, show the photo library
    if (TARGET_IPHONE_SIMULATOR) {
        [self showImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
    } else {
        // Otherwiser, give the user a choice via an action sheet
        UIActionSheet *actionSheet =
        [[UIActionSheet alloc] initWithTitle:@""
                                    delegate:self
                           cancelButtonTitle:@"Cancel"
                      destructiveButtonTitle:nil
                           otherButtonTitles:@"Camera", @"Photo Library", nil];
        [actionSheet showInView:self.view];
    }
}

- (void)showImagePickerController:(UIImagePickerControllerSourceType)sourceType {
    // Initialize an image picker controller for a given source type
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.navigationBar.tintColor = [UIColor whiteColor];
    imagePickerController.sourceType = sourceType;
    imagePickerController.editing = YES;
    imagePickerController.delegate = (id)self;
    // Present the view controller
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)showMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@""
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}

/*
 * A simple way to dismiss the keyboard:
 * whenever the user clicks outside a text field.
 * Also handles click to add or edit a photo
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) event
{
    UITouch *touch = [[event allTouches] anyObject];
    if (![touch.view isKindOfClass:[UITextField class]]) {
        if ([self.firstNameTextField isFirstResponder]) {
            [self.firstNameTextField resignFirstResponder];
        }
        if ([self.lastNameTextField isFirstResponder]) {
            [self.lastNameTextField resignFirstResponder];
        }
        if ([self.companyTextField isFirstResponder]) {
            [self.companyTextField resignFirstResponder];
        }
        if ([self.phoneTextField isFirstResponder]) {
            [self.phoneTextField resignFirstResponder];
        }
        if ([self.emailTextField isFirstResponder]) {
            [self.emailTextField resignFirstResponder];
        }
        if ([self.websiteTextField isFirstResponder]) {
            [self.websiteTextField resignFirstResponder];
        }
    }
    if ([touch.view isEqual:self.cardImageView]) {
        [self addPhotoPressed];
    }
}

@end
