//
//  Cat.m
//  ILoveCatz
//
//  Created by Colin Eberhardt on 22/08/2013.
//  Copyright (c) 2013 com.razeware. All rights reserved.
//

#import "Cat.h"

@implementation Cat

+ (id)catWithImage:(NSString *)image title:(NSString *)title attribution:(NSString *)attribution{
    Cat* cat = [Cat new];
    cat.image = image;
    cat.title = title;
    cat.attribution = attribution;
    return cat;
}

@end
