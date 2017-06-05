//
//  MTRReactiveEngine.h
//  Reactor
//
//  Created by Ty Cobb on 1/15/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

@import Foundation;

@protocol MTRReactive;
@interface MTRReactiveEngine : NSObject

/**
 @brief Adds reactivity to marked classes
 
 Sweeps the class list for classes adopting @c MTRReactive, and swizzles their
 property setters/getters to add reactivity.
*/

+ (void)engage;

/**
 @brief Manually adds reactivity to marked classes
 
 Use this method if you want to have on-demand reactification.
 */

+ (void)reactify:(Class<MTRReactive>)klass;

@end
