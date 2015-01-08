# Reactor
Reactor provides mechanisms for writing reactive code with transparently-defined dependencies. It's based on the Tracker
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

Seems like there's a wizard behind the curtain, right? There is, so let's get a good look at his underthings. Under the hood 
there are some connections being made on the sly between the two building blocks of Reactor, `MTRComputation` and `MTRDependency`.

### Computations
An `MTRComputation` is created every time you call `-autorun:`&mdash;it is an object that encapsulates the block you pass to
the same. Only one computation can run at a time, and the one that's running is what's known as the
```Haskell
"current computation"
```
The block passed to `-autorun:` is called immediately to update the view, but it also has another purpose. Namely, to infer what 
this new computation's *dependencies* are. And how does that happen?

### Dependencies
Here's the wizard's torso (it's what he uses to wave hello):
```Objective-C
- (NSInteger)counter
{
    [self.counterDependency depend];
    return _counter;
}
```

This bit was left off the original example, but it in the accessor for `counter` we were secretly calling `-depend` another 
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
When `-changed` is called on a dependency, and of its dependent computation will be re-run. This updates your UI, re-establishes
the dependency relationships, and kicks-off the cycle all over again. It's not that magical, eh? You've got legs and a torso,
you're just as capable as any wizard.







