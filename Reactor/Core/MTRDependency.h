//
//  MTRDependency.h
//  Reactor
//
//  Created by Ty Cobb on 1/5/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

@import Foundation;

#import "MTRComputation.h"

@interface MTRDependency : NSObject

/** @c YES if this depdendency has one or more dependent computations. */

@property (nonatomic, readonly) BOOL hasDependents;

/**
 @brief Declares that the current computation depends on this dependency.
 
 See @c -depend: for more complete documentation.
 
 @return @c YES when a new dependent computation was added
*/

- (BOOL)depend;

/**
 @brief Declares that a computation depends on this dependency.
 
 If at some point this dependency changes (via the @c -changed method), the dependent
 computation assosciated here (and any others) will be invalidated.
 
 If the @c computation parameter is nil, @c MTRReactor's current computation will be used
 instead.
 
 @param computation The dependent computation, or nil
 @return @c YES when a new dependent computation was added
*/

- (BOOL)depend:(MTRComputation *)computation;

/**
 @brief Invalidates all dependent computations immediately

 Computations are removed as depedents on invalidation.
*/

- (void)changed;

@end
