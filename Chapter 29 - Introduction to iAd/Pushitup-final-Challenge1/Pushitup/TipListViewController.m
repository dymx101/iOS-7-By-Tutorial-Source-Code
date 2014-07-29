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

    Tip *tip = [[Tip alloc] init];
    tip.tipTItle = @"Not too fast";
    tip.tipBody = @"A common mistakes most people make when performing a push-up is going too fast. Try to slow it down and use short contractions, e.g. three seconds. Try to feel the muscle groups you're contracting, and do a full range of motion. Pay attention to the alignment of your elbows. The ideal angle from your sides is around 45 degrees. This allows you to effectively work your chest muscles and prevent overextension. Try to keep your body stiff, elbows should be at a 45-degree angle from your sides, breathe in on the way down, breathe out on the way up.";
    [self.tips addObject:tip];
    
    tip = [[Tip alloc] init];
    tip.tipTItle = @"How to improve";
    tip.tipBody = @"To increase your ability to do push ups, you will need to vary your workouts. With any exercise if the resistance doesn't increase, your muscles won't be overloaded and the stimulus they need need to grow in size will be missing. The best way to increase the resistance is to elevate your feet while doing push-ups. Work up to the point where you can do your push-ups with your feet on a chair";
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

        UIViewController *c = segue.destinationViewController;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            c.interstitialPresentationPolicy = ADInterstitialPresentationPolicyManual;
            [c requestInterstitialAdPresentation];
            
        }
        
        [[segue destinationViewController] setTip:tip];
        
    }
    
}


@end
