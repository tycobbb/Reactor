# Reactor
Reactor in an Objective-C library that provides mechanisms for writing transparently reactive code. It's based on the Tracker
library from [Meteor.js](https://www.meteor.com/), which you can view the source for [here](https://github.com/meteor/meteor/blob/devel/packages/tracker/tracker.js).

## How does it work?
An example reactive function using Reactor looks something like this:
```Objective-C
[MTRReactor autorun:^(MTRComputation *computation) {
    self.counterLabel.text = @(self.counter).description;
}];
```

Which re-runs auto*magic*ally as the counter property updates:
```Objective-C
for(int i=0 ; i<100 ; i++) {
    self.counter++;
}
```

Seems like there's a wizard behind the curtain, right? There is! Let's get a good look at his underthings. Reactor has two core components, `MTRComputation` and `MTRDependency`, that are linked up on the sly by `MTRReactor` to provide reactivity.

### Computations
An `MTRComputation` is created every time you call `-autorun:`&mdash;it's an object that encapsulates the block you pass to
the same. Only one computation can run at a time, and the running computation is known as the
```Haskell
"current computation"
```
The block passed to `-autorun:` is called immediately to update the view, but it's also used to infer what 
this new computation's *dependencies* are. How does that happen?

### Dependencies
Here's the wizard's torso (it's what he uses to wave hello):
```Objective-C
- (NSInteger)counter
{
    [self.counterDependency depend];
    return _counter;
}
```

This bit was left off the original example. In the accessor for `counter` we're secretly calling `-depend` another 
property, `counterDependency`, which we created earlier:
```Objective-C
self.counterDependency = [MTRDependency new]
```
When you call `-depend` on a dependency, Reactor looks at the current computation and adds it as a *dependent* of your 
dependency. The legs, the powertrain:
```Objective-C
- (void)setCounter:(NSInteger)counter
{
    _counter = counter;
    [self.counterDependency changed];
}
```
When `-changed` is called on a dependency, all of its *dependent* computations will be re-run. This updates your UI, re-establishes the dependent relationships, and kicks-off the cycle all over again. It's not that magical, eh? With legs and a torso you're as capable as any wizard.

## Declarative Reactivity

Creating all those dependencies is pretty tedious. Worse, if you override the setter and getter for a property to trigger a dependency its storage isn't `@synthesized` anymore and you have to do it manually.

Enter `MTRReactive`. Annotate any of your classes with this protocol, and all its properties become implicitly reactive:
```Objective-C
@interface Person : NSObject <MTRReactive>
@property (copy  , nonatomic) NSString *name;
@property (assign, nonatomic) NSInteger age;
@end
```

If you want to whitelist/blacklist certain properties, you can implement *either* `+reactiveProperties:` *or* `+nonreactiveProperties:`, respectively.

There are a few caveats to keep in mind:
- Just because your superclass adopts `MTRReactive` doesn't mean your properties are also reactive. Every class that wants reactivity must adopt the protocol independently.
- Properties which don't have a setter won't be reactive, as there's no way to invalidate its dependency.
- You'll need to register classes conforming to `MTRReactive`, and there are two ways of doing that:
    1. Automatically, sending a message to `[MTRReactor engage]`.
    You can do that, for example, on `- (BOOL)applicationDidFinishLaunching:`.
    
    2. On-demand, sending a message to `[MTRReactor reactify:self.class]`.
    You can override `+ (void)initialize` and add that message.

You can then react to your objects' properties in computations like normal:
```Objective-C
[MTRReactor autorun:^(MTRComputation *computation) {
    self.ageLabel = @(person.age).description;
}];
```
