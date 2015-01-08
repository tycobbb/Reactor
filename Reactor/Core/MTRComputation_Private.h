//
//  MTRComputation_Private.h
//  Reactor
//
//  Created by Ty Cobb on 1/7/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRComputation.h"

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