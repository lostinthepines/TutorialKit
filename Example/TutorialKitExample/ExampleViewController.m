//
//  ExampleViewController.m
//  TutorialKitExample
//
//  Created by Alex on 4/30/14.
//  Copyright (c) 2014 TutorialKit. All rights reserved.
//

#import "ExampleViewController.h"
#import "TutorialKit.h"

@interface ExampleViewController()
@property (nonatomic, weak) UIButton *nextButton;
@property (nonatomic, weak) UIButton *startButton;
@property (nonatomic, weak) UIView *topBar;
@end
@implementation ExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:self.repeatingBackground];
    
    BOOL displayToolbar = YES;
    UIBarButtonItem *theItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(nextStep:)];
    theItem.tag = 1001;
    
    if (displayToolbar) {
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        [toolbar setItems:@[theItem]];
        [self.view addSubview:toolbar];
        _topBar = toolbar;
    }
    else{
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"Navigation Bar"];
        [navItem setLeftBarButtonItem:theItem];
        [navBar setItems:@[navItem]];
        [self.view addSubview:navBar];
        _topBar = navBar;
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 200.f, 60.f);
    [btn setTitle:@"START" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateHighlighted];
    btn.backgroundColor = [UIColor colorWithRed:0.3 green:0.7 blue:0.3 alpha:1.0];
    btn.layer.cornerRadius = 15.f;
    [btn addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    self.startButton = btn;
    
    // a reset button
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 200.f, 60.f);
    [btn setTitle:@"LAST STEP" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateHighlighted];
    btn.backgroundColor = [UIColor colorWithRed:0.8 green:0.3 blue:0.3 alpha:1.0];
    btn.layer.cornerRadius = 15.f;
    btn.tag = 1002;
    [btn addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    self.nextButton = btn;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    CGPoint center = self.view.center;
    if(orientation == UIInterfaceOrientationLandscapeLeft ||
       orientation == UIInterfaceOrientationLandscapeRight) {
        center.x = self.view.center.y;
        center.y = self.view.center.x;
    }
    self.topBar.frame = CGRectMake(0, 20, self.view.frame.size.width,44);
    self.startButton.center = CGPointMake(center.x, center.y * 0.5);
    self.nextButton.center = CGPointMake(center.x, self.startButton.center.y + 100.f);
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
