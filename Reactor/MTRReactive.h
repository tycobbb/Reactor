//
//  MTRReactive.h
//  Reactor
//
//  Created by Ty Cobb on 1/15/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

@import Foundation;

@protocol MTRReactive <NSObject> @optional

/**
 @brief Returns a list of non-reactive keys 

 Any properties whose keys are not returned in this will have an implicity dependency
 created for them if they are accessed inside a computation.

 @return An array of string keys corresponding to properties on the reactive class
*/

+ (NSArray *)nonreactive;

@end
