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
#import "MTRReactor+Operators.h"

@interface MTRViewController () <UITextFieldDelegate>
@property (copy  , nonatomic) NSString *thoughts;
@property (strong, nonatomic) MTRDependency *thoughtsDependency;
@property (weak  , nonatomic) IBOutlet UILabel *responseLabel;
@end

@implementation MTRViewController

@synthesize thoughts=_thoughts;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        _thoughtsDependency = [MTRDependency new];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    [MTRReactor autorun:^(MTRComputation *computation) {
        self.responseLabel.text = [self evaluateThoughts:self.thoughts];
    }];
    
    [[MTRReactor reactor] throttle:0.5f block:^(MTRComputation *computation) {
        self.responseLabel.text = [self respondToThoughts:self.thoughts];
    }];
}

- (NSString *)evaluateThoughts:(NSString *)thoughts
{
    return @"Hmm...";
}

- (NSString *)respondToThoughts:(NSString *)thoughts
{
    if(!thoughts.length) {
        return @"Hmm...";
    }
    
    thoughts = [NSString stringWithFormat:@"%@? That's funny.", thoughts];
    thoughts = [thoughts stringByReplacingOccurrencesOfString:@"I'm" withString:@"You're" options:NSCaseInsensitiveSearch range:(NSRange){ .length = thoughts.length }];
    
    return thoughts;
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
