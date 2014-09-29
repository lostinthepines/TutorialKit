/*
 TutorialKit.m
 Created by Alex on 4/21/14.
 Copyright (c) 2014 DANIEL. All rights reserved.
 
 The MIT License (MIT)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "TutorialKit.h"
#import "UIView+Recursion.h"
#import "TutorialKitView.h"

#define TKSequence @"TutorialKitSequence"
#define TKStep @"TutorialKitStep"
#define TKUserDefaultsKey @"TutorialKitUserDefaults"

@interface TutorialKit()
@property (nonatomic, strong) NSMutableDictionary *sequences;
@property (nonatomic, strong) TutorialKitView *currentTutorialView;
@property (nonatomic, strong) UIColor *backgroundTintColor;
@property (nonatomic, strong) UIColor *labelColor;
@property (nonatomic, strong) UIFont *labelFont;
@property (nonatomic) CGFloat blurAmount;
@property (nonatomic) BOOL shouldContinue;
@end

@implementation TutorialKit

#pragma mark - Public

////////////////////////////////////////////////////////////////////////////////
+ (void)addTutorialSequence:(NSArray *)sequence name:(NSString*)name
{
    NSInteger step = [TutorialKit currentStepForTutorialWithName:name];;
    [TutorialKit.sharedInstance.sequences setObject:@{TKSequence:sequence,TKStep:@(step)} forKey:name];
}

////////////////////////////////////////////////////////////////////////////////
+ (BOOL)advanceTutorialSequenceWithName:(NSString *)name
{
    return [TutorialKit advanceTutorialSequenceWithName:name andContinue:NO];
}

////////////////////////////////////////////////////////////////////////////////
+ (BOOL)advanceTutorialSequenceWithName:(NSString *)name andContinue:(BOOL)shouldContinue
{
    if(TutorialKit.sharedInstance.currentTutorialView) {
        // a tutorial view is already visible
        return NO;
    }
    
    NSMutableDictionary *sequenceData = [TutorialKit.sharedInstance.sequences objectForKey:name];
    if(!sequenceData) {
        // assert?
        return NO;
    }
    
    if(![sequenceData isKindOfClass:NSMutableDictionary.class]) {
        sequenceData = sequenceData.mutableCopy;
    }
    
    NSNumber *step = [sequenceData objectForKey:TKStep];
    if(nil == step) {
        step = @(0);
        [sequenceData setObject:step forKey:TKStep];
    }
    
    NSArray *sequence = [sequenceData objectForKey:TKSequence];
    if(!sequence) {
        // assert?
        return NO;
    }
    
    if(step.integerValue >= sequence.count || step.integerValue < 0) {
        // sequence step is invalid or sequence is over
        return NO;
    }
    
    NSMutableDictionary *current = [sequence objectAtIndex:step.integerValue];
    if(!current) {
        // assert?
        return NO;
    }
    else if(![current isKindOfClass:NSMutableDictionary.class]) {
        // ensure this is a mutable copy
        current = current.mutableCopy;
    }

    if(![current objectForKey:TKMessageFont]) {
        [current setObject:TutorialKit.sharedInstance.labelFont forKey:TKMessageFont];
    }
    
    if(![current objectForKey:TKMessageColor]) {
        [current setObject:TutorialKit.sharedInstance.labelColor forKey:TKMessageColor];
    }
    
    if(![current objectForKey:TKBlurAmount]) {
        [current setObject:@(TutorialKit.sharedInstance.blurAmount) forKey:TKBlurAmount];
    }
    
    if([current objectForKey:TKHighlightViewTag]) {
        UIView *highlightView = [TutorialKit.sharedInstance
                                 findViewWithTag:[current objectForKey:TKHighlightViewTag]];
        if(highlightView) {
            [current setObject:highlightView forKey:TKHighlightView];
        }
        else {
            // highlight view not found! assert?
            return NO;
        }
    }

    TutorialKitView *tkv = [TutorialKitView tutorialViewWithDictionary:current];
    if(tkv) {
        tkv.sequenceStep = step.integerValue;
        tkv.sequenceName = name;
        tkv.tintColor = TutorialKit.sharedInstance.backgroundTintColor;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:TutorialKit.sharedInstance
                                                 action:@selector(dismissTutorialView:)];
        [tkv addGestureRecognizer:tapRecognizer];
        TutorialKit.sharedInstance.currentTutorialView = tkv;
        TutorialKit.sharedInstance.shouldContinue = shouldContinue;
        [TutorialKit presentTutorialView:tkv withAnimation:YES];
    }
    
    return tkv != NULL;
}

////////////////////////////////////////////////////////////////////////////////
+ (BOOL)advanceTutorialSequenceWithName:(NSString *)name ifOnStep:(NSInteger)step
{
    return [TutorialKit advanceTutorialSequenceWithName:name
                                               ifOnStep:step
                                            andContinue:NO];
}

////////////////////////////////////////////////////////////////////////////////
+ (BOOL)advanceTutorialSequenceWithName:(NSString *)name
                               ifOnStep:(NSInteger)step
                            andContinue:(BOOL)shouldContinue
{
    if([TutorialKit currentStepForTutorialWithName:name] != step) {
        return NO;
    }
    
    return [TutorialKit advanceTutorialSequenceWithName:name andContinue:shouldContinue];
}

////////////////////////////////////////////////////////////////////////////////
+ (NSInteger)currentStepForTutorialWithName:(NSString *)name
{
    NSMutableDictionary *sequence = [TutorialKit.sharedInstance.sequences objectForKey:name];
    if(sequence) {
        NSNumber *step = [sequence objectForKey:TKStep];
        if(step) return step.integerValue;
    }
    else {
        // check NSUserDefaults for a stored tutorial step
        NSInteger step = 0;
        if([NSUserDefaults.standardUserDefaults objectForKey:TKUserDefaultsKey]) {
            NSMutableDictionary *steps = [NSUserDefaults.standardUserDefaults objectForKey:TKUserDefaultsKey];
            if([steps objectForKey:name]) {
                step = [[steps objectForKey:name] integerValue];
            }
        }
        return step;
    }
    
    return 0;
}

////////////////////////////////////////////////////////////////////////////////
+ (UIView *)currentTutorialView
{
    return TutorialKit.sharedInstance.currentTutorialView;
}

////////////////////////////////////////////////////////////////////////////////
+ (void)dismissCurrentTutorialView
{
    if(TutorialKit.sharedInstance.currentTutorialView) {
        [TutorialKit.sharedInstance
         dismissTutorialView:TutorialKit.sharedInstance.currentTutorialView];
    }
}


////////////////////////////////////////////////////////////////////////////////
+ (void)insertTutorialSequence:(NSArray *)sequence name:(NSString*)name afterStep:(NSInteger)step
{
    [TutorialKit insertTutorialSequence:sequence name:name beforeStep:step + 1];
}

////////////////////////////////////////////////////////////////////////////////
+ (void)insertTutorialSequence:(NSArray *)sequence name:(NSString*)name beforeStep:(NSInteger)step
{
    NSDictionary *existingSequence = [TutorialKit.sharedInstance.sequences objectForKey:name];
    if(!existingSequence) {
        // @TODO Error message?
        return;
    }
    
    NSInteger curStep = [TutorialKit currentStepForTutorialWithName:name];
    NSArray *steps = existingSequence[TKSequence];
    if(step >= steps.count) {
        steps = [steps arrayByAddingObjectsFromArray:sequence];
    }
    else if(step > 0) {
        NSMutableArray *newSequence = @[].mutableCopy;
        [newSequence addObjectsFromArray:[steps subarrayWithRange:NSMakeRange(0, step)]];
        [newSequence addObjectsFromArray:sequence];
        [newSequence addObjectsFromArray:[steps subarrayWithRange:NSMakeRange(step, steps.count - step)]];
        steps = newSequence;
    }
    else {
        steps = [sequence arrayByAddingObjectsFromArray:steps];
    }
    
    [TutorialKit.sharedInstance.sequences setObject:@{TKSequence:steps,TKStep:@(curStep)} forKey:name];
}

////////////////////////////////////////////////////////////////////////////////
+ (void)presentTutorialView:(TutorialKitView *)view withAnimation:(BOOL)animate
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    if(windows && windows.count > 0) {
        UIWindow *window = [windows objectAtIndex:0];
        [window addSubview:view];
        view.frame = window.bounds;
        [view setNeedsLayout];
        
        if(animate) {
            // fade in
            view.alpha = 0;
            [UIView animateWithDuration:0.5 animations:^{
                view.alpha = 1;
            } completion:nil];
        }
        else {
            view.alpha = 1.;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
+ (void)setCurrentStep:(NSInteger)step forTutorial:(NSString *)name
{
    NSMutableDictionary *sequence = [TutorialKit.sharedInstance.sequences objectForKey:name];
    if(sequence) {
        if(![sequence isKindOfClass:NSMutableDictionary.class]) {
            sequence = sequence.mutableCopy;
        }
        
        [sequence setObject:@(step) forKey:TKStep];
        
        // save to NSUserDefaults
        NSMutableDictionary *steps = [NSUserDefaults.standardUserDefaults objectForKey:TKUserDefaultsKey];
        if(!steps) {
            steps = @{}.mutableCopy;
        }
        else {
            steps = steps.mutableCopy;
        }
        [steps setObject:@(step) forKey:name];
        [NSUserDefaults.standardUserDefaults setObject:steps forKey:TKUserDefaultsKey];

        [TutorialKit.sharedInstance.sequences setObject:sequence forKey:name];
    }
}

////////////////////////////////////////////////////////////////////////////////
+ (void)setDefaultBlurAmount:(CGFloat)amount
{
    TutorialKit.sharedInstance.blurAmount = MAX(0.0,MIN(1.0,amount));
}

////////////////////////////////////////////////////////////////////////////////
+ (void)setDefaultMessageColor:(UIColor *)color
{
    TutorialKit.sharedInstance.labelColor = color;
}

////////////////////////////////////////////////////////////////////////////////
+ (void)setDefaultMessageFont:(UIFont *)font
{
    TutorialKit.sharedInstance.labelFont = font;
}

////////////////////////////////////////////////////////////////////////////////
+ (void)setDefaultTintColor:(UIColor *)color
{
    TutorialKit.sharedInstance.backgroundTintColor = color;
}

#pragma mark - Private

////////////////////////////////////////////////////////////////////////////////
- (UIColor *)backgroundTintColor
{
    if(!_backgroundTintColor) {
        _backgroundTintColor = [UIColor colorWithWhite:1.f alpha:0.5];
    }
    
    return _backgroundTintColor;
}

////////////////////////////////////////////////////////////////////////////////
- (void)dismissTutorialView:(TutorialKitView *)view
{
    if(view.sequenceName && view.sequenceStep >= 0) {
        // get the tutorial sequence with this name
        NSMutableDictionary *sequenceData = [TutorialKit.sharedInstance.sequences
                                             objectForKey:view.sequenceName];
        if(!sequenceData) {
            // assert?
            return;
        }
        else if(![sequenceData isKindOfClass:NSMutableDictionary.class]) {
            sequenceData = sequenceData.mutableCopy;
        }
        
        // increment the tutorial step
        [sequenceData setObject:@(view.sequenceStep + 1) forKey:TKStep];
        
        // save to NSUserDefaults
        NSMutableDictionary *steps = [NSUserDefaults.standardUserDefaults objectForKey:TKUserDefaultsKey];
        if(!steps) {
            steps = @{}.mutableCopy;
        }
        else {
            steps = steps.mutableCopy;
        }
        [steps setObject:@(view.sequenceStep + 1) forKey:view.sequenceName];
        [NSUserDefaults.standardUserDefaults setObject:steps forKey:TKUserDefaultsKey];
        
        // run the callback if one exists
        if(view.values && [view.values objectForKey:TKCompleteCallback]) {
            void (^callback)();
            callback = [view.values objectForKey:TKCompleteCallback];
            callback();
        }
        [TutorialKit.sharedInstance.sequences setObject:sequenceData
                                                 forKey:view.sequenceName];
    }
    if(view == TutorialKit.sharedInstance.currentTutorialView) {
        TutorialKit.sharedInstance.currentTutorialView = nil;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        view.alpha = 0;
    } completion:^(BOOL finished) {
        if(TutorialKit.sharedInstance.shouldContinue) {
            [TutorialKit advanceTutorialSequenceWithName:view.sequenceName];
        }
        else {
            [view removeFromSuperview];
        }
    }];
}

////////////////////////////////////////////////////////////////////////////////
- (UIView *)findViewWithTag:(NSNumber *)tag
{
    // look for the view with this tag
    __block UIView *tagView = nil;
    for(UIWindow *window in UIApplication.sharedApplication.windows) {
        [window.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            if(view.hidden || view.alpha == 0) return;
            
            tagView = [view findViewRecursively:^BOOL(UIView *subview, BOOL *stop) {
                if(subview.tag == tag.integerValue && !subview.hidden &&
                   subview.alpha != 0) {
                    *stop = YES;
                    return NO;
                }
                // return yes if should recurse further
                return !subview.hidden && subview.alpha != 0;
            }];
            
            if(tagView) *stop = YES;
        }];
        
        if(tagView) break;
    }
    
    return tagView;
}

////////////////////////////////////////////////////////////////////////////////
- (UIColor *)labelColor
{
    if(!_labelColor) {
        _labelColor = UIColor.grayColor;
    }
    return _labelColor;
}

////////////////////////////////////////////////////////////////////////////////
- (UIFont *)labelFont
{
    if(!_labelFont) {
        _labelFont = [UIFont fontWithName:@"Helvetica" size:16];
    }
    return _labelFont;
}

////////////////////////////////////////////////////////////////////////////////
- (void)onTapGesture:(UITapGestureRecognizer *)gesture
{
    if(!gesture.view || ![gesture.view isKindOfClass:TutorialKitView.class]) {
        // assert?
        return;
    }
    
    [self dismissTutorialView:(TutorialKitView *)gesture.view];
}

////////////////////////////////////////////////////////////////////////////////
- (NSMutableDictionary *)sequences
{
    if(!_sequences) {
        _sequences = @{}.mutableCopy;
    }
    return _sequences;
}

////////////////////////////////////////////////////////////////////////////////
+ (TutorialKit *)sharedInstance
{
    static TutorialKit *tk = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!tk) tk = [[TutorialKit alloc] init];
        tk.currentTutorialView = nil;
        tk.blurAmount = 1.0;
    });
    
    return tk;
}

@end
