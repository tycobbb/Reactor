//
//  MTRReactor+Operators.m
//  Reactor
//
//  Created by Ty Cobb on 1/7/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRReactor+Operators.h"

@implementation MTRReactor (Operators)

- (MTRComputation *)throttle:(NSTimeInterval)timeout block:(void (^)(MTRComputation *))block
{
    NSParameterAssert(block);
    
    return [self.class autorun:^(MTRComputation *computation) {
        
    }];
}

@end
