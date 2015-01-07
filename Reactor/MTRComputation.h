//
//  MTRComputation.h
//  Reactor
//
//  Created by Ty Cobb on 1/5/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

@import Foundation;

@protocol MTRComputationDelegate;

@interface MTRComputation : NSObject

/** Responsible for responding to scheduling and configuration events */
@property (weak, nonatomic) id<MTRComputationDelegate> delegate;

/** A unique identifier for this computation */
@property (nonatomic, readonly) id identifier;

/** The enclosing computation, if this was triggered inside another computation */
@property (nonatomic, readonly) MTRComputation *parent;

/** @c YES if the computation has been stopped. */
@property (nonatomic, readonly) BOOL isStopped;

/** @c YES if the computation has been invalidated (and not yet rerun), or if it has been stopped */
@property (nonatomic, readonly) BOOL isInvalid;

/** @c YES until the computation has run once (in @c -autorun: ) */
@property (nonatomic, readonly) BOOL isFirstRun;

/**
 @brief Initializes a new computation

 The computation will only have a parent if it was triggered inside another computation.

 @param identifier A unique identifier for this computation
 @param block      The computation's runnable code
 @param parent     The enclosing computation
*/

- (instancetype)initWithId:(id)identifier block:(void(^)(MTRComputation *))block parent:(MTRComputation *)parent;

/**
 @brief Stops the computaiton, preventing it from re-running
 
 Stop also invalidates (but does not run) the computation, which cleans up any existing relationshpis 
 to dependencies.
*/

- (void)stop;

/**
 @brief Marks a computation to be re-run
 
 If the computation is already invalid, this does nothing. Any @c -onInvalidate: handlers are invoked
 before this method completes.
*/

- (void)invalidate;

/**
 @brief Registers a handler to run when the computation is invalidated
 
 If the computation is already invalid, the handler fires immediately. Handlers are discarded after
 they're invoke, so @c -onInvalidate: should be called again if repeat callbacks are necessary.
 
 @param handler The handler to invoke on invalidation. Receives the computation as a parameter.
*/

- (void)onInvalidate:(void(^)(MTRComputation *))handler;

@end
