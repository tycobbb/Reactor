//
//  MTRComputation.h
//  Reactor
//
//  Created by Ty Cobb on 1/5/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

@import Foundation;

/**
 @brief A computation encapsulates a runnable block of code
 
 Computations should only be created through @c -autorun: on @c MTRReactor. Computations
 run as long as it has dependencies that change or until the use calls stop manually.
*/

@interface MTRComputation : NSObject

/** @c A unique identifier for this computation */
@property (nonatomic, readonly) id identifier;

/** @c The enclosing computation, if this was triggered inside another computation */
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

- (instancetype)initWithId:(id)identifier block:(void(^)(void))block parent:(MTRComputation *)parent;

@end
