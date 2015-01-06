//
//  MTRReactor.m
//  Reactor
//
//  Created by Ty Cobb on 1/5/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRReactor_Private.h"

@implementation MTRReactor

# pragma mark - Flushing 

- (void)scheduleFlush
{
    if(!self.flushScheduled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self flush];
        });
        self.flushScheduled = YES;
    }
    
}

- (void)flush
{
    
}

# pragma mark - Accessors

- (BOOL)isActive
{
    return self.currentComputation != nil;
}

@end
