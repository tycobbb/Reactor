//
//  MTRComputation_Private.h
//  Reactor
//
//  Created by Ty Cobb on 1/7/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRComputation.h"

@interface MTRComputation ()
/** A list of handlers to call after the computation has invalidated */
@property (strong, nonatomic) NSMutableArray *invalidateHandlers;
/** The computation's runnable code */
@property (copy, nonatomic) void(^block)(MTRComputation *);
// read-write version of public property
@property (assign, nonatomic) BOOL isStopped;
// read-write version of public property
@property (assign, nonatomic) BOOL isInvalid;
/** @c YES while the computation is being re-run */
@property (assign, nonatomic) BOOL isRecomputing;
/** @c YES if the dependencies should be preserved on invalidation. Defaults to @c NO. */
@property (assign, nonatomic) BOOL keepsDependenciesOnInvalidation;
@end

@interface MTRComputation (Computation)

/**
 @brief Invokes the computation
 
 Any dependencies assosciated during computation will cause the computation to
 recompute.
*/

- (void)compute;

/**
 @brief Invokes the computation
 
 This method is called during flushing, and internally calls compute.
 
 Any depdendencies assosciated during computation will cause the computation to
 recompute again.
*/

- (void)recompute;

@end