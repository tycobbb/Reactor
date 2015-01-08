//
//  MTRReactor+Operators.m
//  Reactor
//
//  Created by Ty Cobb on 1/7/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRReactor+Operators.h"
#import "MTRThrottle.h"

@implementation MTRReactor (Operators)

- (MTRComputation *)throttle:(NSTimeInterval)timeout block:(void (^)(MTRComputation *))block
{
    NSParameterAssert(block);
    // create a throttle to manage the timeout
    MTRThrottle *throttle = [[MTRThrottle alloc] initWithTimeout:timeout block:block];
    // the throttle creates the computation internally
    return throttle.computation;
}

@end
