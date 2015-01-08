//
//  MTRThrottle.m
//  Reactor
//
//  Created by Ty Cobb on 1/7/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRThrottle.h"
#import "MTRDependency.h"

@interface MTRThrottle ()
@property (strong, nonatomic) MTRDependency *dependency;
@end

@implementation MTRThrottle

- (instancetype)initWithTimeout:(NSTimeInterval)timeout
{
    if(self = [super init]) {
        _timeout = timeout;
        _dependency = [MTRDependency new];
    }
    
    return self;
}

@end
