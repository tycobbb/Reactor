//
//  MTRDependency.m
//  Reactor
//
//  Created by Ty Cobb on 1/5/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRDependency.h"
#import "MTRReactor_Private.h"

@interface MTRDependency ()
/** A map computations keyed by ID currently depending on this dependency */
@property (strong, nonatomic) NSMutableDictionary *dependentsMap;
@end

@implementation MTRDependency

- (instancetype)init
{
    if(self = [super init]) {
        _dependentsMap = [NSMutableDictionary new];
    }
    
    return self;
}

# pragma mark - Dependent Assoscation

- (BOOL)depend
{
    return [self depend:nil];
}

- (BOOL)depend:(MTRComputation *)computation
{
    // use the current computation if we don't have one
    computation = computation ?: [MTRReactor reactor].currentComputation;
    if(!computation) {
        return NO;
    }
    
    // if we don't have this computation as a dependent, then let's add it
    if(!self.dependentsMap[computation.identifier]) {
        self.dependentsMap[computation.identifier] = computation;
        [computation onInvalidate:^(MTRComputation *computation) {
            [self.dependentsMap removeObjectForKey:computation.identifier];
        }];
        
        return YES;
    }
    
    return NO;
}

- (void)changed
{
    for(MTRComputation *computation in self.dependentsMap.allValues) {
        [computation invalidate];
    }
}

# pragma mark - Accessors

- (BOOL)hasDependents
{
    return self.dependentsMap.count != 0;
}

@end
