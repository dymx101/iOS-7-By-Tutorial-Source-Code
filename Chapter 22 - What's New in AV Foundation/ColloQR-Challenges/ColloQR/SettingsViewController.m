//
//  SettingsViewController.m
//  ColloQR
//
//  Created by Matt Galloway on 22/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (nonatomic, weak) IBOutlet UISlider *speedSlider;
@property (nonatomic, weak) IBOutlet UISlider *volumeSlider;
@property (nonatomic, weak) IBOutlet UISlider *pitchSlider;
@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _speedSlider.value = [defaults floatForKey:@"Speed"];
    _volumeSlider.value = [defaults floatForKey:@"Volume"];
    _pitchSlider.value = [defaults floatForKey:@"Pitch"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:_speedSlider.value forKey:@"Speed"];
    [defaults setFloat:_volumeSlider.value forKey:@"Volume"];
    [defaults setFloat:_pitchSlider.value forKey:@"Pitch"];
}

@end
