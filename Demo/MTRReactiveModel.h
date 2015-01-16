//
//  MTRReactiveModel.h
//  Reactor
//
//  Created by Ty Cobb on 1/15/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

@import UIKit;

#import "MTRReactive.h"

@interface MTRReactiveModel : NSObject <MTRReactive>
@property (nonatomic) NSString *name;
@property (nonatomic, readonly) NSString *age;
@property (nonatomic, getter=state) NSString *status;
@property (nonatomic) short num;
@property (nonatomic) CGRect rect;
@property (nonatomic) CGPoint point;
@property (copy, nonatomic) void(^block)(void);
@end

@interface MTRReactiveSubmodel : MTRReactiveModel <MTRReactive>
@property (nonatomic) NSString *face;
@end
