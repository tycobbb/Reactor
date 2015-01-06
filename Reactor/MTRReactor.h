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

@end
