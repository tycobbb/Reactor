//
//  MTRThrottle.m
//  Reactor
//
//  Created by Ty Cobb on 1/7/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRThrottle.h"
#import "MTRReactor.h"
#import "MTRDependency.h"
#import "MTRComputation_Private.h"

@interface MTRThrottle ()
/** The dependency that invalidates the computation when throttling finishes */
@property (strong, nonatomic) MTRDependency *dependency;
/** Timestamp of the last call to @c -throttle */
@property (assign, nonatomic) NSTimeInterval lastUpdate;
/** @c YES when the there is an active timeout dispatched  */
@property (assign, nonatomic) BOOL isActive;
/** Defaults to @c YES. Also @c YES after a timeout elapses. Accessing @c -isReady clears the flag, setting it to @c NO. */
@property (assign, nonatomic) BOOL isReady;
@end

@implementation MTRThrottle

- (instancetype)initWithTimeout:(NSTimeInterval)timeout block:(void (^)(MTRComputation *))block
{
    if(self = [super init]) {
        _isReady = YES;
        _timeout = timeout;
        _dependency = [MTRDependency new];
        _computation = [self autorun:block];
    }
    
    return self;
}

- (MTRComputation *)autorun:(void(^)(MTRComputation *))block
{
    // create a computation which internally calls the throttled block when the we're ready
    MTRComputation *computation = [MTRReactor autorun:^(MTRComputation *computation) {
        if(self.isReady) {
            block(computation);
        } else {
            [self throttle];
        }
    }];
    
    // we need to keep the dependencies alive so that it can throttle the block's logic
    computation.keepsDependenciesOnInvalidation = YES;
    
    return computation;
}

# pragma mark - Throttling

/** 
 @brief Resets the throttle
 
 The throttle won't fire until the timeout elapses after the last call to @c -throttle. 
 This method is reactive, and it will invalidate the computation when the timeout 
 completes.
*/

- (void)throttle
{
    // track the last update time
    self.lastUpdate = CFAbsoluteTimeGetCurrent();
   
    // if there's no active timeout, start one
    if(!self.isActive) {
        [self initiateTimeout:self.timeout];
    }
    
    [self.dependency depend];
}


- (void)initiateTimeout:(NSTimeInterval)timeout
{
    self.isActive = YES;
   
    mtr_dispatch_after_seconds(self.timeout, ^{
        // check if we've actually finished the timeout. will only be true if another update
        // hasn't come in since the last dispatch
        NSTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
        NSTimeInterval timeLeft = self.timeout - (currentTime - self.lastUpdate);
    
        self.isActive = NO;
        
        // if we're not done, initiate a timeout for the leftovers
        if(timeLeft >= 0) {
            [self initiateTimeout:timeLeft];
        }
        // otherwise, we've finished throttling
        else {
            [self timeoutFinished];
        }
    });
}

- (void)timeoutFinished
{
    [self setIsReady:YES];
    [self.dependency changed];
}

# pragma mark - Accessors

- (BOOL)isReady
{
    // isReady is cleared whenever it's called
    BOOL isReady = _isReady;
    _isReady = NO;
    return isReady;
}

# pragma mark - Helpers

void mtr_dispatch_after_seconds(NSTimeInterval interval, void(^callback)(void))
{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), callback);
}

@end
