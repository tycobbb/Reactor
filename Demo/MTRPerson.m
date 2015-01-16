//
//  MTRPerson.m
//  Reactor
//
//  Created by Ty Cobb on 1/15/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRPerson.h"

@implementation MTRPerson

@end

@implementation MTRLawyer

+ (NSArray *)nonreactiveProperties:(id)object
{
    // `fullname` doesn't _need_ to be explicitly reactive (though it certainly
    // could be), because it's a pass-through to name (which is reactive).
    
    return @[
        @"fullname"
    ];
}

- (NSString *)fullname
{
    return [NSString stringWithFormat:@"%@ Marhsall Thomas Esq", self.name];
}

- (NSInteger)age
{
    return _age ?: 10;
}

@end
