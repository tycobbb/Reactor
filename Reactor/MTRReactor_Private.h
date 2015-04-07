//
//  MTRReactor_Private.h
//  Reactor
//
//  Created by Ty Cobb on 1/5/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRReactor.h"
#import "MTRReactiveEngine.h"
#import "MTRLogging.h"

@interface MTRReactor ()
@property (strong, nonatomic) MTRComputation *currentComputation;
/** The integer ID that will be assigned to the next created computation */
@property (assign, nonatomic) NSInteger nextId;
/** Computations waiting to be flushed */
@property (strong, nonatomic) NSMutableArray *pendingComputations;
/** Blocks to be called before the current flush finishes */
@property (strong, nonatomic) NSMutableArray *afterFlushHandlers;
/** Blocks to be called once the flush completes */
@property (strong, nonatomic) NSMutableArray *clearFlushHandlers;
/** @c YES when a pending computation flush is scheduled or is in progress */
@property (assign, nonatomic) BOOL flushScheduled;
/** @c YES when pending computations are being flushed */
@property (assign, nonatomic) BOOL isFlushing;
/** @c YES when running a computation, either reactively or non-reactively */
@property (assign, nonatomic) BOOL isComputing;
/** @c YES if the reactivity is disabled completely */
@property (assign, nonatomic) BOOL isDisabled;
@end

@interface MTRReactor (Scheduling)

/**
 @brief Adds the computation of the list of computations to be invoked
 
 If the reactor didn't have a flush scheduled, then this also schedules a flush
 of pending computations on the next frame.
 
 @param computation The computation to schedule
 */

- (void)scheduleComputation:(MTRComputation *)computation;

/**
 @brief Provides a hook around computation execution
 
 The reactor performs bookkeeping around calling the block to track nested computation
 execution, and runs the parameterized block in-between.
 
 @param computation The computation that's executing
 @param block       The computation block to call
 */

- (void)computation:(MTRComputation *)computation executeWithBlock:(void(^)(void))block;

@end

@interface NSMutableArray (Utility)

/**
 @brief Pops the object off the front of the array
 
 If there are no objects left, returns nil.
 
 @return The first object in the array.
 */

- (id)mtr_shift;

@end
