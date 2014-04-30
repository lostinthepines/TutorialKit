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
                           TKHighlightViewTag: @(1001),
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
    
    // some optional defaults
    [TutorialKit setDefaultBlurAmount:0.5];
    [TutorialKit setDefaultMessageColor:UIColor.grayColor];
    [TutorialKit setDefaultTintColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
