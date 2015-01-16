//
//  MTRReactor.h
//  Reactor
//
//  Created by Ty Cobb on 1/5/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRComputation.h"

@interface MTRReactor : NSObject

/**
 @brief True if there is a computation being computed
 
 Dependencies which are accessed and depended on while the reactor is active
 may cause computations to be re-run when they're invalidated.
*/

@property (nonatomic, readonly) BOOL isActive;

/**
 @brief The computation currently being computed, if any.
 
 If there is no active computation, this property returns @c nil. Otherwise, this is
 the innermost triggered computation. Dependencies depended on while the reactor 
 is active will by default add this as a dependent.
*/

@property (nonatomic, readonly) MTRComputation *currentComputation;

/**
 @brief Starts a new computation with the given block
 
 The computation is run immediately, and any will depend on any depdencies triggered
 during this execution. If in those future any of the dependencies change, the
 computation will be recomputed.
 
 @param block The block for the computation to invoke
 @return The newly created computation
*/

+ (MTRComputation *)autorun:(void(^)(MTRComputation *))block;

/**
 @brief Starts a new computation for the given target action pair
 
 The action should accept one parameter, the computation, similar to the block equivalent
 of this method.
 
 @see -autorun: for more detailed documentation.
 
 @param target The target for the action
 @param action The action to execute
 
 @return The newly created computation
*/

+ (MTRComputation *)autorun:(id)target action:(SEL)action;

/**
 @brief Executes a block that won't trigger any dependencies
 
 This is useful for running non-reactive code within a computation that may trigger 
 dependencies you'd rather not attach to the computation.
 
 @param block The non-reactive code
*/

+ (void)nonreactive:(void(^)(void))block;

/**
 @brief Returns the shared reactor
 
 This is a shared instance method, and you can use this to access any of the
 reactor's instance properties / methods.
 
 @return The shared MTRReactor instance
*/

+ (instancetype)reactor;

/**
 @brief Schedules handler to run when the current computation is invalidated
 
 This method throws an exception if there is no current computation. Otherwise,
 when the computation is invalidated it will call this block.
 
 @brief handler The handler to call on invalidation 
*/

- (void)onInvalidate:(void(^)(MTRComputation *))handler;

/**
 @brief Schedules a handler to run after the next, or current, flush
 
 This method also schedules a flush if there isn't already one scheduled. The handler is 
 discarded after it's called. Call @c -aferFlush: again to schedule a repeat handler.
 
 @param handler The handler to schedule
*/

- (void)afterFlush:(void(^)(void))handler;

@end

//
// Errors
//

extern NSString * const MTRReactorError;
