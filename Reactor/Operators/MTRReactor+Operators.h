//
//  MTRReactor+Operators.h
//  Reactor
//
//  Created by Ty Cobb on 1/7/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRReactor.h"

@interface MTRReactor (Operators)

/**
 @brief Autoruns a computation that is throttled over an interval
 
 Any attempts to re-run a computation will be throttled until the @c timeout
 has elapsed since the last attempt. At that point the computation will be
 evaluated.
 
 @param timeout The throttle timeout in seconds
 @param block   The block to invoke for the computation
 
 @return The new computation
*/

- (MTRComputation *)throttle:(NSTimeInterval)timeout block:(void(^)(MTRComputation *))block;

@end
