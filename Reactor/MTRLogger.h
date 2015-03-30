//
//  MTRLogger.h
//  Reactor
//
//  Created by Ty Cobb on 3/27/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

@import Foundation;

@class MTRComputation;

@interface MTRLogger : NSObject

/**
 @brief Returns the shared logger

 The logger exposes functionality for logging messages to the console, and it may be
 enabled or disabled by toggling the @c MTRLogging define.
*/

+ (instancetype)logger;

/**
 @brief Logs a message to the console

 If no computation is specified, this functions like a normal log message. If it is 
 specified, the message will only fire if the computation is currently being tracked.
 
 @param computation The computation to log against
 @param format      The format of the message to log
*/

- (void)log:(MTRComputation *)computation format:(NSString *)format, ...;

/**
 Tracks a computation, allow computation-specific log messages to fire.
 
 @param computation The computation to track
*/

- (void)track:(MTRComputation *)computation;

@end
