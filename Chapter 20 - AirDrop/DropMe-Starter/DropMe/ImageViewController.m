//
//  ImageViewController.m
//  DropMe
//
//  Created by Soheil Azarpour on 6/25/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "ImageViewController.h"

@import MobileCoreServices;
@import AVFoundation;

@interface ImageViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end

@implementation ImageViewController

#pragma mark
#pragma mark - IBActions

- (IBAction)photoAlbumButtonTapped:(id)sender
{
    [self presentImagePickerViewControllerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)cameraButtonTapped:(id)sender
{
    [self presentImagePickerViewControllerWithSourceType:UIImagePickerControllerSourceTypeCamera];
}

#pragma mark
#pragma mark - Helper methods

/*
 * A helper method to configure and display image picker controller based
 * on the source type. Assumption is that source types are either
 * photo library or camera.
 */
- (void)presentImagePickerViewControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = sourceType;
    controller.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    controller.allowsEditing = NO;
    controller.delegate = self;
    
    [self presentViewController:controller animated:YES completion:nil];
}

/*
 * Create an snapshot of a movie at a given URL and return UIImage.
 */
- (UIImage*)snapshotFromMovieAtURL:(NSURL *)movieURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:movieURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    NSError *error = nil;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:NULL error:&error];
    return [[UIImage alloc] initWithCGImage:imageRef];
}

#pragma mark
#pragma mark - UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // What did user pick? Is it a movie or is it an image?
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    // If it is an image...
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        // Update UI and the object to share.
        self.imageView.image = info[UIImagePickerControllerOriginalImage];
    }
    // else, if it is a movie...
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Get the URL to the movie for sharing
        NSURL *assetURL = info[UIImagePickerControllerMediaURL];
        
        // Update UI by taking an snapshot of the movie.
        self.imageView.image = [self snapshotFromMovieAtURL:assetURL];
    }
    
    // Dismiss the picker.
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
