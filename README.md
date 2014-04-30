# TutorialKit

[![Version](http://cocoapod-badges.herokuapp.com/v/TutorialKit/badge.png)](http://cocoadocs.org/docsets/TutorialKit)
[![Platform](http://cocoapod-badges.herokuapp.com/p/TutorialKit/badge.png)](http://cocoadocs.org/docsets/TutorialKit)

![alt tag](https://github.com/lostinthepines/TutorialKit/raw/master/Assets/tutorialkit.gif)

TutorialKit is a library for creating interactive step by step tutorials.  Highlight views with action messages, and show gestures without adding a lot of extra logic code to your app.


## Usage

**Simple example:**

- Add a tutorial sequence (the same one used in the gif above)
```Objective-C
    // Set up in the AppDelegate (but could be anywhere really)
    NSValue *msgPoint = [NSValue valueWithCGPoint:
                         CGPointMake(self.window.bounds.size.width * 0.5,
                                     self.window.bounds.size.height * 0.65)];
    NSValue *swipeStart = [NSValue valueWithCGPoint:
                           CGPointMake(self.window.bounds.size.width * 0.75,
                                       self.window.bounds.size.height * 0.75)];
    NSValue *swipeEnd = [NSValue valueWithCGPoint:
                           CGPointMake(self.window.bounds.size.width * 0.25,
                                       self.window.bounds.size.height * 0.75)];

    // set up a simple 3 step tutorial
    NSArray *steps = @[
                       // Step 0
                       @{
                           TKHighlightViewTag: @(1001), // tag assigned to your UIButton
                           TKMessage: @"First, press this button.",
                           TKMessagePoint: msgPoint
                           },
                       // Step 1
                       @{
                           TKSwipeGestureStartPoint: swipeStart,
                           TKSwipeGestureEndPoint: swipeEnd,
                           TKMessage: @"Next, swipe left.",
                           TKMessagePoint: msgPoint
                           },
                       // Step 2
                       @{
                           TKMessage: @"That's it! Yer all done!",
                           TKMessagePoint: msgPoint,
                           TKCompleteCallback: ^{ NSLog(@"ALL DONE."); }
                           },
                       ];
    
    [TutorialKit addTutorialSequence:steps name:@"example"];
```

- At any point in the application where you want to advance the tutorial:
```Objective-C
    [TutorialKit advanceTutorialSequenceWithName:@"example"];
```

- Profit.

**You can also configure the TutorialKit default styles.**
```Objective-C
    [TutorialKit setDefaultBlurAmount:0.5];
    [TutorialKit setDefaultMessageColor:UIColor.grayColor];
    [TutorialKit setDefaultMessageFont:[UIFont fontWithName:@"Helvetica" size:20]];
    [TutorialKit setDefaultTintColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
``` 

**At any time you can set the tutorial step (useful if you want to start over)**
```Objective-C
    [TutorialKit setCurrentStep:0 forTutorial:@"example"];
```

To run the example project; clone the repo, and run `pod install` from the Example directory first.

## Installation

TutorialKit is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "TutorialKit"

## Author

Alex Peterson, alex@inthepin.es 

## License

TutorialKit is available under the MIT license. See the LICENSE file for more info.

