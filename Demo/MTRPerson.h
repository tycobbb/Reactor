//
//  MTRPerson.h
//  Reactor
//
//  Created by Ty Cobb on 1/15/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

@import UIKit;

#import "MTRReactive.h"

@interface MTRPerson : NSObject <MTRReactive>
@property (copy, nonatomic) NSString *name;
@end

@interface MTRLawyer : MTRPerson <MTRReactive>
@property (assign, nonatomic) NSInteger age;
@property (assign, nonatomic) CGRect body;
@property (copy  , nonatomic, readonly) NSString *fullname;
@end
