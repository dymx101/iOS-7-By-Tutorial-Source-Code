//
//  SMPushupListViewController.m
//  Pushitup
//
//  Created by Cesare Rocchi on 7/9/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import "PushupListViewController.h"
#import "Pushup.h"
#import "PushCell.h"
#import "PushupViewController.h"
#import "NewPushupViewController.h"

@interface PushupListViewController ()

@property (nonatomic, strong) NSMutableArray *pushups;

@end

@implementation PushupListViewController

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

    self.pushups = [NSMutableArray array];
    
    NSInteger i = 0;
    
    while (i < 15) {
        
        int randNum = rand() % (40 - 1) + 1;
        Pushup *p = [[Pushup alloc] initWithPushups:randNum];
        [self.pushups addObject:p];
        i++;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addNewPushup:)
                                                 name:kAddNewPushup
                                               object:nil];
        
}

#pragma mark - Actions

- (void) addNewPushup:(NSNotification *) notification {

    Pushup *pushup = (Pushup*)notification.object;
    [self.pushups addObject:pushup];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    [self.pushups sortUsingDescriptors:@[sortDescriptor]];
    [self.collectionView reloadData];
    
}


#pragma mark - Collection view

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.pushups.count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    PushCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"PUSH_CELL" forIndexPath:indexPath];
    Pushup *push = self.pushups[indexPath.row];
    cell.dateLabel.text = [push stringDate];
    cell.pushupsLabel.text = [NSString stringWithFormat:@"%i", push.numberOfPushups];
    
    NSIndexPath *previousIndexPath = [NSIndexPath indexPathForItem:indexPath.row-1 inSection:0];
    Pushup *prevPushup = nil;
        
    if (previousIndexPath.row >= 0) {
    
        prevPushup = self.pushups[previousIndexPath.row];
        
    }
    
    if (prevPushup) {
    
        if (prevPushup.numberOfPushups >= push.numberOfPushups) {
        
            cell.arrowImageView.image = [UIImage imageNamed:@"arrowDown"];

        } else {
        
            cell.arrowImageView.image = [UIImage imageNamed:@"arrowUp"];
            
        }
        
    } else {
    
        cell.arrowImageView.image = nil;
        
    }
    
    return cell;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems][0];
        Pushup *p = self.pushups[indexPath.row];
        Pushup *previousPushup = nil;
        
        if (indexPath.row > 0)
            previousPushup = self.pushups[indexPath.row-1];
        
        [segue.destinationViewController setPushUp:p];
        [segue.destinationViewController setPreviousPushUp:previousPushup];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
