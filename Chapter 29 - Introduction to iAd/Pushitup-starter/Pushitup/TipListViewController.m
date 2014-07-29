//
//  TipListViewController.m
//  Pushitup
//
//  Created by Cesare Rocchi on 7/9/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import "TipListViewController.h"
#import "Tip.h"
#import "TipViewController.h"

@interface TipListViewController ()

@property (nonatomic, strong) NSMutableArray *tips;

@end

@implementation TipListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tips = [NSMutableArray array];
    
//    int i = 0;
//    
//    while (i < 20) {
//        
//        Tip *tip = [[Tip alloc] init];
//        tip.tipTItle = [NSString stringWithFormat:@"Tip %i", i];
//        tip.tipBody = @"Common mistakes most people make when performing a push-up include going too fast and using only partial range of motion. In the video above, Darin Steen demonstrates the perfect push-up. First, slow it down and use a three-second contraction. Try to really feel the muscle groups you're targeting, and do a full range of motion -- starting all the way down at the floor and pushing all the way up. Pay particular attention to the alignment of your elbows. The ideal angle from your sides is about 45 degrees. This allows you to effectively work your chest muscles and prevent injuries from overextension. I recommend watching Darin's demonstration of the proper form, but here's a summary of key points to remember: Keep your body stiff and straight as a plank Elbows at a 45-degree angle from your sides Breathe in on the way down Lower your body all the way down, allowing your sternum to gently touch the floor        Breathe out on the way up";
//        [self.tips addObject:tip];
//        i++;
//        
//    }

    Tip *tip = [[Tip alloc] init];
    tip.tipTItle = @"Not too fast";
    tip.tipBody = @"Common mistakes most people make when performing a push-up include going too fast and using only partial range of motion. In the video above, Darin Steen demonstrates the perfect push-up. First, slow it down and use a three-second contraction. Try to really feel the muscle groups you're targeting, and do a full range of motion -- starting all the way down at the floor and pushing all the way up. Pay particular attention to the alignment of your elbows. The ideal angle from your sides is about 45 degrees. This allows you to effectively work your chest muscles and prevent injuries from overextension. I recommend watching Darin's demonstration of the proper form, but here's a summary of key points to remember: Keep your body stiff and straight as a plank Elbows at a 45-degree angle from your sides Breathe in on the way down Lower your body all the way down, allowing your sternum to gently touch the floor Breathe out on the way up.";
    [self.tips addObject:tip];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tips.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TipCell";
    Tip *tip = self.tips[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = tip.tipTItle;
    cell.detailTextLabel.text = tip.tipBody;
    
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Tip *tip = self.tips[indexPath.row];
        [[segue destinationViewController] setTip:tip];
        
    }
}


@end
