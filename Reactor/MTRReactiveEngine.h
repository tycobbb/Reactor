//
//  MTRReactiveEngine.h
//  Reactor
//
//  Created by Ty Cobb on 1/15/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

@import Foundation;

@interface MTRReactiveEngine : NSObject

/**
 @brief Adds reactivity to marked classes
 
 Sweeps the class list for classes adopting @c MTRReactive, and swizzles their
 property setters/getters to add reactivity.
*/

+ (void)engage;

@end
