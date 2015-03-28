//
//  AppDelegate.m
//  TutorialKitExample
//
//  Created by Alex on 4/30/14.
//  Copyright (c) 2014 TutorialKit. All rights reserved.
//

#import "AppDelegate.h"
#import "ExampleViewController.h"
#import "TutorialKit.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[ExampleViewController alloc] init];
    
    NSValue *msgPoint = [NSValue valueWithCGPoint:
                         CGPointMake(0.5,0.7)];
    NSValue *swipeStart = [NSValue valueWithCGPoint:
                           CGPointMake(0.75,0.8)];
    NSValue *swipeEnd = [NSValue valueWithCGPoint:
                           CGPointMake(0.25,0.8)];
    // set up a simple 3 step tutorial
    NSArray *steps = @[
                       // Step 0
                       @{
                           TKHighlightViewTag: @(1001),
                           TKMessage: @"First, press this button.",
                           TKMessageRelativePoint: msgPoint
                           },
                       // Step 1
                       @{
                           TKSwipeGestureRelativeStartPoint: swipeStart,
                           TKSwipeGestureRelativeEndPoint: swipeEnd,
                           TKMessage: @"Next, swipe left.",
                           TKMessageRelativePoint: msgPoint
                           },
                       // Step 2
                       @{
                           TKMessage: @"That's it! Yer all done!",
                           TKMessageRelativePoint: msgPoint,
                           TKCompleteCallback: ^{ NSLog(@"ALL DONE."); }
                           },
                       ];
    
    [TutorialKit addTutorialSequence:steps name:@"example"];
    
    // insert an extra step
    NSArray *moreSteps = @[
                           @{
                               TKHighlightViewTag: @(1002),
                               TKMessage: @"Please press this button to finish.",
                               TKMessageRelativePoint: msgPoint
                               },
                           ];
    [TutorialKit insertTutorialSequence:moreSteps name:@"example" beforeStep:2];
    
    // some optional defaults
    [TutorialKit setDefaultBlurAmount:0.5];
    [TutorialKit setDefaultMessageColor:UIColor.grayColor];
    [TutorialKit setDefaultTintColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
