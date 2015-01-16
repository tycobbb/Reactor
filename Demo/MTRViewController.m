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
#import "MTRReactiveModel.h"

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
    
    self.thoughts = @"I'm good.";
    
    MTRReactiveModel *model = [MTRReactiveModel new];
    model.name = @"John";
  
    [MTRReactor autorun:^(MTRComputation *computation) {
        self.responseLabel.text = [self respondToThoughts:self.thoughts forPerson:model.name];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        model.name = @"Jane";
    });
}

- (NSString *)respondToThoughts:(NSString *)thoughts forPerson:(NSString *)person
{
    if(!thoughts.length) {
        return @"Hmm...";
    }
    
    thoughts = [NSString stringWithFormat:@"%@? That's funny %@.", thoughts, person];
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
