//
//  SelectEffectViewController.m
//  iGuitar
//
//  Created by Matt Galloway on 19/06/2013.
//  Copyright (c) 2013 Matt Galloway. All rights reserved.
//

#import "SelectEffectViewController.h"

#import "Effect.h"

@import AudioUnit;
@import AudioToolbox;

@interface SelectEffectViewController ()

@end

@implementation SelectEffectViewController {
    NSArray *_effects;
}

#pragma mark -

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self refreshList];
}

- (IBAction)closeTapped:(id)sender {
    [_delegate selectEffectViewControllerWantsToClose:self];
}

- (void)refreshList {
    // 1
    NSMutableArray *effects = [NSMutableArray new];
    
    // 2
    AudioComponentDescription searchDesc = { kAudioUnitType_RemoteEffect, 0, 0, 0, 0 };
    
    // 3
    AudioComponent component = NULL;
    while ((component = AudioComponentFindNext(component, &searchDesc))) {
        // 4
        AudioComponentDescription description;
        OSStatus err = AudioComponentGetDescription(component, &description);
        if (err) continue;
        
        // 5
        Effect *effect = [[Effect alloc] init];
        effect.componentDescription = description;
        effect.icon = AudioComponentGetIcon(component, 44.0f);
        
        CFStringRef name;
        AudioComponentCopyName(component, &name);
        effect.name = (__bridge NSString *)name;
        
        [effects addObject:effect];
    }
    
    // 6
    _effects = effects;
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _effects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Effect *effect = _effects[indexPath.row];
    cell.imageView.image = effect.icon;
    cell.textLabel.text = effect.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Effect *effect = _effects[indexPath.row];
    [_delegate selectEffectViewController:self didSelectEffect:effect];
}

@end
