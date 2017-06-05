//
//  MTRAppDelegate.m
//  Reactor
//
//  Created by Ty Cobb on 1/5/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRAppDelegate.h"
#import "MTRReactor.h"

@implementation MTRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MTRReactor engage];
    
    return YES;
}

@end
