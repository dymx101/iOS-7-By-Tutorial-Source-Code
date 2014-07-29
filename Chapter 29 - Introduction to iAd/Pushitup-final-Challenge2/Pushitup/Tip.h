//
//  SMTip.h
//  Pushitup
//
//  Created by Cesare Rocchi on 6/27/13.
//  Copyright (c) 2013 Cesare Rocchi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectWithDate.h"

@interface Tip : ObjectWithDate

@property (nonatomic, strong) NSString *tipTItle;
@property (nonatomic, strong) NSString *tipBody;


@end
