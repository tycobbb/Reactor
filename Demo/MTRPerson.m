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

- (NSString *)fullname
{
    return [NSString stringWithFormat:@"%@ Marhsall Thomas Esq", self.name];
}

- (NSInteger)age
{
    return _age ?: 10;
}

@end
