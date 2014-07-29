//
//  AddGuestTableViewController.m
//  WaitList
//
//  Created by Chris Wagner on 7/24/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "AddGuestTableViewController.h"
#import "Guest.h"
#import "GuestService.h"
#import "NSNumber+SpokenTime.h"

NSInteger const kAddGuestNameCellTag = 1;
NSInteger const kAddGuestArrivalTimeCellTag = 2;
NSInteger const kAddGuestQuotedTimeCellTag = 3;
NSInteger const kAddGuestMoodCellTag = 4;
NSInteger const kAddGuestNotesCellTag = 5;

@implementation UINavigationController (DelegateAutomaticDismissKeyboard)
// allow keyboard dismissal in UIModalPresentationFormSheet
- (BOOL)disablesAutomaticKeyboardDismissal {
    return [self.topViewController disablesAutomaticKeyboardDismissal];
}

@end

@interface AddGuestTableViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate> {
    NSArray *_quoteTimes;
    NSInteger _selectedCellTag;
    NSIndexPath *_selectedIndexPath;
    NSDateFormatter *_arrivalDateFormatter;
    BOOL _editMode;
}

@property (weak, nonatomic) IBOutlet UIDatePicker *arrivalTimePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *quotedTimePicker;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *partySizeTextField;
@property (weak, nonatomic) IBOutlet UILabel *setArrivalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *setQuotedTimeLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *moodSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@end

@implementation AddGuestTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _quoteTimes = @[@5, @10, @15, @20, @25, @30, @35, @40, @45, @60, @75, @90, @105, @120];
    [_quotedTimePicker setHidden:YES];
    [_arrivalTimePicker setHidden:YES];
    [_arrivalTimePicker setDate:[NSDate date]];

    _arrivalDateFormatter = [GuestService sharedInstance].arrivalDateFormatter;
    [_arrivalDateFormatter setDateFormat:@"hh:mm a"];
    _setArrivalTimeLabel.text = [_arrivalDateFormatter stringFromDate:_arrivalTimePicker.date];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_guest) {
        [self populateForm];
        _editMode = YES;
    } else {
        [_nameTextField becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

- (void)populateForm {
    _nameTextField.text = _guest.name;
    _partySizeTextField.text = [NSString stringWithFormat:@"%d", _guest.partySize];
    _arrivalTimePicker.date = _guest.arrivalTime;
    _setArrivalTimeLabel.text = [_arrivalDateFormatter stringFromDate:_arrivalTimePicker.date];
    [_quotedTimePicker selectRow:[_quoteTimes indexOfObject:_guest.quotedTime] inComponent:0 animated:NO];
    _setQuotedTimeLabel.text = [_guest.quotedTime spokenTime];
    [_moodSegmentedControl setSelectedSegmentIndex:_guest.mood];
    _notesTextView.text = _guest.notes;
}

- (BOOL)validateForm {
    NSMutableString *validationMessage = [NSMutableString string];
    BOOL hasValidationError = NO;
    if (_nameTextField.text.length == 0) {
        hasValidationError = YES;
        [validationMessage appendString:@"Name"];
    }
    
    if (_partySizeTextField.text.length == 0) {
        hasValidationError = YES;
        if (validationMessage.length) {
            [validationMessage appendString:@" and Party Size are required."];
        } else {
            [validationMessage appendString:@"Party Size is required."];
        }
    } else {
        [validationMessage appendString:@" is required"];
    }
    
    if (hasValidationError) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Required Fields" message:validationMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    return !hasValidationError;
}

- (IBAction)cancelButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonTouched:(id)sender {
    if ([self validateForm]) {
        if (!_guest) {
            _guest = [[Guest alloc] init];
        }
        
        _guest.name = _nameTextField.text;
        _guest.partySize = [_partySizeTextField.text integerValue];
        _guest.arrivalTime = _arrivalTimePicker.date;
        _guest.quotedTime = _quoteTimes[[_quotedTimePicker selectedRowInComponent:0]];
        _guest.mood = _moodSegmentedControl.selectedSegmentIndex;
        _guest.notes = _notesTextView.text;

        if (_editMode) {
            [[GuestService sharedInstance] removeGuest:_guest];
        }
        
        NSInteger index = [[GuestService sharedInstance] addGuest:_guest];
        [self.delegate guestAdded:_guest atIndex:index];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)editingDidBeginOnNameField:(id)sender {
    [self hidePickers];
}

- (IBAction)editingDidBeginOnPartySizeField:(id)sender {
    [self hidePickers];
}

- (IBAction)moodSelectorValueChanged:(id)sender {
    [self.view endEditing:YES];
    [self hidePickers];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _partySizeTextField) {
        if (string.length == 0) {
            return YES;
        }
        NSCharacterSet *nonNumberCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        return [string stringByTrimmingCharactersInSet:nonNumberCharacterSet].length > 0;
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _nameTextField) {
        [_partySizeTextField becomeFirstResponder];
    } else if (textField == _partySizeTextField) {
        [_partySizeTextField resignFirstResponder];
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self hidePickers];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:1]]) { // notes index path
        return 200.0;
    }
    
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:3 inSection:0]]) { // arrival time picker
        if (_arrivalTimePicker.hidden) {
            return 0;
        } else {
            return 216.0;
        }
    }
    
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:5 inSection:0]]) { // quoted time picker
        if (_quotedTimePicker.hidden) {
            return 0;
        } else {
            return 216.0;
        }
    }
    
    return 44.0;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell.tag == kAddGuestArrivalTimeCellTag) {
        [self.view endEditing:YES];
        [tableView beginUpdates];
        [self hideQuotedTimePicker];
        [self toggleArrivalTimePicker];
        [tableView endUpdates];
    } else if (cell.tag == kAddGuestQuotedTimeCellTag) {
        [self.view endEditing:YES];
        [tableView beginUpdates];
        [self hideArrivalTimePicker];
        [self toggleQuotedTimePicker];
        [tableView endUpdates];
    } else {
        // hide the pickers otherwise
        [self hidePickers];
    }
}

- (void)hidePickers {
    [self.tableView beginUpdates];
    [self hideArrivalTimePicker];
    [self hideQuotedTimePicker];
    [self.tableView endUpdates];
}

- (void)hideArrivalTimePicker {
    [_arrivalTimePicker setHidden:YES];
}

- (void)hideQuotedTimePicker {
    [_quotedTimePicker setHidden:YES];
}

- (void)toggleArrivalTimePicker {
    if (_arrivalTimePicker.hidden) {
        [_arrivalTimePicker setHidden:NO];
    } else {
        [_arrivalTimePicker setHidden:YES];
    }
}

- (void)toggleQuotedTimePicker {
    if (_quotedTimePicker.hidden) {
        [_quotedTimePicker setHidden:NO];
    } else {
        [_quotedTimePicker setHidden:YES];
    }
}

- (IBAction)arrivalTimeValueChanged:(id)sender {
    _setArrivalTimeLabel.text = [_arrivalDateFormatter stringFromDate:_arrivalTimePicker.date];
}

#pragma mark - Picker view data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_quoteTimes count];
}

#pragma mark - Picker view delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSNumber *quoteTime = _quoteTimes[row];
    return [quoteTime spokenTime];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSNumber *quoteTime = _quoteTimes[row];
    _setQuotedTimeLabel.text = [quoteTime spokenTime];
}

@end
