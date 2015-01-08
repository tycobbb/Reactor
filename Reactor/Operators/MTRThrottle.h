//
//  MTRThrottle.h
//  Reactor
//
//  Created by Ty Cobb on 1/7/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

@import Foundation;

@interface MTRThrottle : NSObject

/** The interval to throttle updates for */
@property (nonatomic, readonly) NSTimeInterval timeout;

/**
 @brief Initializes a new throttle
 
 @c MTRThrottle manages the dependencies necessary to keep a computation alive
 while throttling attempted re-runs.
 
 @param timeout The interval to throttle over
 @return A new MTRThrottle instance
*/

- (instancetype)initWithTimeout:(NSTimeInterval)timeout;

@end
