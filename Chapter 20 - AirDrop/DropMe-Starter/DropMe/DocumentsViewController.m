//
//  DocumentsViewController.m
//  DropMe
//
//  Created by Soheil Azarpour on 6/27/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "DocumentsViewController.h"

@import MobileCoreServices;

@interface DocumentsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *documents;
@property (nonatomic, strong) NSMutableArray *toShare;
@end

@implementation DocumentsViewController

#pragma mark
#pragma mark - view life cycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    /*
     * Register for SADocumentsDirectoryContentDidChangeNotification notification
     * to update UI whenever a new file comes in.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateViewWithNotification:)
                                                 name:DocumentsDirectoryContentDidChangeNotification
                                               object:nil];
    
    [[UITableView appearance] setTintColor:RGBColor(135.0, 193.0, 230.0)];
    [super viewDidLoad];
}

#pragma mark
#pragma mark - Custom getters and setters

- (NSMutableArray *)documents
{
    if (!_documents)
    {
        /*
         * Fetch a list of files in user documents directory.
         * Since the app handles its own custom file types,
         * filter fetched results with NSURLTypeIdentifierKey
         * to get the resource’s uniform type identifier (UTI).
         */
        
        NSArray *properties = @[NSURLTypeIdentifierKey];
        NSError *error = nil;
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:UserDocumentsDirectory()
                                                       includingPropertiesForKeys:properties
                                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                            error:&error];
        if (!files)
        {
            NSLog(@"Error getting the list of documents in user documents directory: %@", error.localizedDescription);
        }
        else
        {
            // Enumerate in the returned list of documents and pick
            // those we want.
            NSMutableArray *documents = [NSMutableArray array];
            [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                NSURL *file = (NSURL *)obj;
                NSDictionary *values = [file resourceValuesForKeys:properties error:nil];
                NSString *fileType = values[NSURLTypeIdentifierKey];
                NSString *fileExtension = file.pathExtension;
                
                // If it is a DropMe custom file type, add it to the array.
                NSArray *acceptableFileTypes = @[kUTTypeDropMe];
                NSArray *acceptableFileExtensions = @[@"dm"];
                if ([acceptableFileTypes containsObject:fileType] || [acceptableFileExtensions containsObject:fileExtension])
                {
                    [documents addObject:file];
                }
            }];
            _documents = documents;
        }
    }
    return _documents;
}

- (NSMutableArray *)toShare
{
    if (!_toShare)
    {
        _toShare = [NSMutableArray array];
    }
    return _toShare;
}

#pragma mark
#pragma mark - UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.documents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell identifier"];
    
    NSURL *documents = self.documents[indexPath.row];
    cell.textLabel.text = documents.lastPathComponent;
    
    // Toggle the checkmark.
    if ([self.toShare containsObject:documents])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the document's URL user tapped
    NSURL *document = self.documents[indexPath.row];
    
    // If it is already selected, de-select it and remove it from the collection to share.
    // Otherwise, add it to the collection to share.
    [self updateDocumentsToShareWithDocument:document];
    
    // Update UI.
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *document = self.documents[indexPath.row];
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] removeItemAtURL:document error:&error];
    if (success)
    {
        // If it is one of the selected items to be shared, remove it!
        if ([self.toShare containsObject:document])
        {
            [self updateDocumentsToShareWithDocument:document];
        }
        
        // Update the data source and UI.
        [self.documents removeObject:document];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        NSLog(@"Error deleting document [%@]. %@", document, error.localizedDescription);
    }
}

#pragma mark
#pragma mark - IBActions

- (IBAction)refreshButtonTapped:(id)sender
{
    // Force update the data source and UI.
    [self updateViewWithNotification:nil];
}

#pragma mark
#pragma mark - Helper methods

/*
 * A helper method to add URL toShare collection or removing from it.
 * If the document is already in the collection, it takes it out. If
 * it is not in the collection, it adds it in.
 */
- (void)updateDocumentsToShareWithDocument:(NSURL *)document
{
    if ([self.toShare containsObject:document])
    {
        [self.toShare removeObject:document];
    }
    else
    {
        [self.toShare addObject:document];
    }
}

/*
 * Force update the data source and UI.
 */
- (void)updateViewWithNotification:(NSNotification *)notification
{
    self.toShare = nil;
    self.documents = nil;
    [self.tableView reloadData];
}

@end
