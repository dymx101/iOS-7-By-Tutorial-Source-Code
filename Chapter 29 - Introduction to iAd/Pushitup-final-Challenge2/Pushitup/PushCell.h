//
//  PushCell.h
//  Pushitup
//
//  Created by Cesare Rocchi on 7/9/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PushCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *pushupsLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *arrowImageView;


@end
