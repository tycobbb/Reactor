//
//  MTRLogger.m
//  Reactor
//
//  Created by Ty Cobb on 3/27/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRLogger.h"
#import "MTRComputation.h"

@interface MTRLogger ()
/** The weak set of tracked computations */
@property (strong, nonatomic) NSHashTable *computations;
@end

@implementation MTRLogger

+ (instancetype)logger
{
    static MTRLogger *logger;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [self new];
    });
    
    return logger;
}

- (instancetype)init
{
    if(self = [super init]) {
        _computations = [NSHashTable weakObjectsHashTable];
    }
    
    return self;
}

- (void)log:(MTRComputation *)computation format:(NSString *)format, ...
{
    if(!computation || [self.computations containsObject:computation]) {
        va_list args;
        va_start(args, format);
       
        // format the log message, optionally prepending computation info
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        if(computation) {
            message = [[NSString alloc] initWithFormat:@"computation: %@ %@", computation.identifier, message];
        }
        
        // log to the console with no formatting
        printf("[reactor] %s\n", message.UTF8String);
        
        va_end(args);
    }
}

- (void)track:(MTRComputation *)computation
{
    [self.computations addObject:computation];
}

@end
