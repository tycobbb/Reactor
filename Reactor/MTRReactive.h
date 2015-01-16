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
 @brief Blacklist non-reactive keys

 Any properties whose keys are not returned are assosciated with an implicit dependency
 when accessed inside a computation.
 
 @attention Mutually exclusive with @c +reactive:

 @param object A placeholder instance; always nil
 @return An array of string keys corresponding to properties on the reactive class
*/

+ (NSArray *)nonreactiveProperties:(id)object;

/**
 @brief Whitelist of reactive keys
 
 Any properties whose keys are returned are assosciated with an implicit dependency
 when accessed inside a computation.
 
 @attention Mutually exclusive with @c +nonreactive:
 
 @param object A placeholder instance; always nil
 @return An array of string keys corresponding to properties on the reactive class
*/

+ (NSArray *)reactiveProperties:(id)object;

@end
