//
//  MTRViewController.m
//  Reactor
//
//  Created by Ty Cobb on 1/5/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

#import "MTRViewController.h"
#import "MTRReactor.h"
#import "MTRDependency.h"
#import "MTRPerson.h"

@interface MTRViewController () <UITextFieldDelegate>
@property (copy  , nonatomic) NSString *thoughts;
@property (assign, nonatomic) NSInteger ticks;
@property (strong, nonatomic) MTRDependency *thoughtsDependency;
@property (strong, nonatomic) MTRDependency *ticksDependency;
@property (weak  , nonatomic) IBOutlet UILabel *responseLabel;
@property (weak  , nonatomic) IBOutlet UILabel *timeLabel;
@property (weak  , nonatomic) IBOutlet UITextField *adviceField;
@end

@implementation MTRViewController

@synthesize thoughts=_thoughts;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        _thoughtsDependency = [MTRDependency new];
        _ticksDependency = [MTRDependency new];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    // set up initial conditions
    self.adviceField.text = @"You should take the plea.";
    self.thoughts = self.adviceField.text;
    
    MTRLawyer *lawyer = [MTRLawyer new];
    lawyer.name = @"John";

    // run reactions
    [MTRReactor autorun:self action:@selector(tick:)];
    [MTRReactor autorun:^(MTRComputation *computation) {
        self.responseLabel.text = [self respondToThoughts:self.thoughts forLawyer:lawyer];
    }];
    
    // invalidate reactions
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        lawyer.name = @"Jane";
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        lawyer.age = 7;
    });
}

- (NSString *)respondToThoughts:(NSString *)thoughts forLawyer:(MTRLawyer *)lawyer
{
    if(!thoughts.length) {
        return @"Hmm...";
    }
    
    if([thoughts hasSuffix:@"."]) {
        thoughts = [thoughts substringToIndex:thoughts.length-1];
    }
    
    thoughts = [NSString stringWithFormat:@"%@? That's nice %@, but I don't take advice from %d year-old lawyers.", thoughts, lawyer.fullname, (int)lawyer.age];
    thoughts = [thoughts stringByReplacingOccurrencesOfString:@"You" withString:@"I" options:NSCaseInsensitiveSearch range:(NSRange){ .length = thoughts.length }];
    
    return thoughts;
}

# pragma mark - Reactions

- (void)tick:(MTRComputation *)computation
{
    self.timeLabel.text = @(self.ticks++).description;
    
    if(self.ticks < 11) {
        [self.ticksDependency depend];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.ticksDependency changed];
    });
}

# pragma mark - Interface Actions

- (IBAction)textFieldDidChangeText:(UITextField *)textField
{
    self.thoughts = textField.text;
}

# pragma mark - Thoughts

- (NSString *)thoughts
{
    [self.thoughtsDependency depend];
    return _thoughts;
}

- (void)setThoughts:(NSString *)thoughts
{
    _thoughts = thoughts;
    [self.thoughtsDependency changed];
}

@end
