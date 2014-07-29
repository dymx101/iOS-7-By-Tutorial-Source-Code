//
//  SelectIAAUViewController.m
//  iGuitar
//
//  Created by Matt Galloway on 19/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import "SelectIAAUViewController.h"

#import "InterAppAudioUnit.h"

@import AudioUnit;
@import AudioToolbox;

@interface SelectIAAUViewController ()

@end

@implementation SelectIAAUViewController {
    AudioComponentDescription _searchDesc;
    NSArray *_units;
}

#pragma mark -

- (instancetype)initWithSearchDescription:(AudioComponentDescription)description {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        _searchDesc = description;
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    return [self initWithSearchDescription:(AudioComponentDescription){0}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(closeTapped:)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self refreshList];
}

- (void)closeTapped:(id)sender {
    [_delegate selectIAAUViewControllerWantsToClose:self];
}

- (void)refreshList {
    // 1
    NSMutableArray *units = [NSMutableArray new];
    
    // 2
    AudioComponentDescription searchDesc = _searchDesc;
    
    // 3
    AudioComponent component = NULL;
    while ((component = AudioComponentFindNext(component, &searchDesc))) {
        // 4
        AudioComponentDescription description;
        OSStatus err = AudioComponentGetDescription(component, &description);
        if (err) continue;
        
        // 5
        InterAppAudioUnit *unit = [[InterAppAudioUnit alloc] init];
        unit.componentDescription = description;
        unit.icon = AudioComponentGetIcon(component, 44.0f);
        
        CFStringRef name;
        AudioComponentCopyName(component, &name);
        unit.name = (__bridge NSString *)name;
        
        // 6
        [units addObject:unit];
    }
    
    // 7
    _units = units;
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _units.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    InterAppAudioUnit *unit = _units[indexPath.row];
    cell.imageView.image = unit.icon;
    cell.textLabel.text = unit.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    InterAppAudioUnit *unit = _units[indexPath.row];
    [_delegate selectIAAUViewController:self didSelectUnit:unit];
}

@end
