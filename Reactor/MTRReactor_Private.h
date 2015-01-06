//
//  MTRReactor_Private.h
//  Reactor
//
//  Created by Ty Cobb on 1/5/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRReactor.h"

@interface MTRReactor ()
@property (strong, nonatomic) MTRComputation *currentComputation;
/// The integer ID that will be assigned to the next created computation
@property (assign, nonatomic) NSInteger nextId;
/// Computations waiting to be flushed
@property (strong, nonatomic) NSMutableArray *pendingComputations;
/// Blocks to be called once the flush completes
@property (strong, nonatomic) NSMutableArray *afterFlushHandlers;
/// @c YES when a pending computation flush is scheduled or is in progress
@property (assign, nonatomic) BOOL flushScheduled;
/// @c YES when pending computations are being flushed
@property (assign, nonatomic) BOOL isFlushing;
/// @c YES when running a computation, either reactively or non-reactively
@property (assign, nonatomic) BOOL isComputing;
@end
