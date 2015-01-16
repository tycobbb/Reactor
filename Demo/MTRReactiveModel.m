//
//  MTRReactiveModel.m
//  Reactor
//
//  Created by Ty Cobb on 1/15/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRReactiveModel.h"

@implementation MTRReactiveModel

+ (NSArray *)reactiveProperties:(id)object
{
    return @[
        @"name",
        @"status",
        @"num",
        @"rect"
    ];
}

@end

@implementation MTRReactiveSubmodel

@end
