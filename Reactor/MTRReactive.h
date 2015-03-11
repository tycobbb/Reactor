//
//  MTRReactive.h
//  Reactor
//
//  Created by Ty Cobb on 1/15/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

@import Foundation;

/**
 @brief Addeds transparent reactivity to a class
 
 Any properties on classes annotated with this protocol are made reactive. Each class
 that wishes to make its properties reactive must adopt the protocol independently, even
 if its superclass adopts the protocol.
*/

@protocol MTRReactive <NSObject> @optional

/**
 @brief Destroys this object's dependencies
 
 This method is provided implicitly by adopting this protocol.
 
 Dependencies will be recreated on-demand as if reactions access any of this object's
 reactive properties.
*/

- (void)destroyDependencies;

/**
 @brief Blacklist non-reactive keys

 Any properties whose keys are not returned are assosciated with an implicit dependency
 when accessed inside a computation.
 
 You should not call super from this method.
 
 @attention Mutually exclusive with @c +reactive:

 @param object A placeholder instance; always nil
 @return An array of string keys corresponding to properties on the reactive class
*/

+ (NSArray *)nonreactiveProperties:(id)object;

/**
 @brief Whitelist of reactive keys
 
 Any properties whose keys are returned are assosciated with an implicit dependency
 when accessed inside a computation.
 
 You should not call super from this method.
 
 @attention Mutually exclusive with @c +nonreactive:
 
 @param object A placeholder instance; always nil
 @return An array of string keys corresponding to properties on the reactive class
*/

+ (NSArray *)reactiveProperties:(id)object;

@end
