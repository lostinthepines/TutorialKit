//
//  ExampleViewController.m
//  TutorialKitExample
//
//  Created by Alex on 4/30/14.
//  Copyright (c) 2014 TutorialKit. All rights reserved.
//

#import "ExampleViewController.h"
#import "TutorialKit.h"

@implementation ExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:self.repeatingBackground];
    
    // a button with - note the unique tag
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(60,100,200,60);
    [btn setTitle:@"START" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateHighlighted];
    btn.backgroundColor = [UIColor colorWithRed:0.3 green:0.7 blue:0.3 alpha:1.0];
    btn.layer.cornerRadius = 15.f;
    [btn addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // a reset button
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(60,200,200,60);
    [btn setTitle:@"NEXT STEP" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateHighlighted];
    btn.backgroundColor = [UIColor colorWithRed:0.8 green:0.3 blue:0.3 alpha:1.0];
    btn.layer.cornerRadius = 15.f;
    btn.tag = 1001;
    [btn addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)start:(id)sender
{
    // TutorialKit remembers the current step in NSUserDefaults, but we want to
    // reset the current step every time we press this button
    [TutorialKit setCurrentStep:0 forTutorial:@"example"];
    
    [TutorialKit advanceTutorialSequenceWithName:@"example"];
}

- (void)nextStep:(id)sender
{
    // Auto continue to the next step when the current step is over
    // The default is to not to continue automatically.
    [TutorialKit advanceTutorialSequenceWithName:@"example" andContinue:YES];
}

- (UIImage *)repeatingBackground
{
    // a simple repeating background yo
    UIGraphicsBeginImageContext(CGSizeMake(32,32));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [UIColor.grayColor setStroke];
    CGContextStrokeEllipseInRect(ctx, CGRectMake(2,2,28,28));
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}
@end
