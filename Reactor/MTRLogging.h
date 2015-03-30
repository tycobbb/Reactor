//
//  MTRLogging.h
//  Reactor
//
//  Created by Ty Cobb on 3/27/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRLogger.h"

#define MTRLoggingEnabled 0

#if MTRLoggingEnabled

// logs a message filtered by a specific computation; this message will only fire if
// the computation is being tracked
#define MTRLogComputation(_computation, ...) [[MTRLogger logger] log:_computation format:__VA_ARGS__]

// logs a general message
#define MTRLog(...) MTRLogComputation(nil, __VA_ARGS__)

#else // !MTRLoggingEnabled
#define MTRLog(...)
#define MTRLogComputation(computation, ...)
#endif
