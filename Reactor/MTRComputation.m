//
//  MTRComputation.m
//  Reactor
//
//  Created by Ty Cobb on 1/5/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRComputation.h"

@interface MTRComputation ()
/** A list of handlers to call after the computation has invalidated */
@property (strong, nonatomic) NSMutableArray *invalidateHandlers;
/** The computation's runnable code */
@property (copy, nonatomic) void(^block)(void);
@end

@implementation MTRComputation

- (instancetype)initWithBlock:(void (^)(void))block parent:(MTRComputation *)parent
{
    if(self = [super init]) {
        _block  = block;
        _parent = parent;
        _isFirstRun = YES;
    }
    
    return self;
}

@end
