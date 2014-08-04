/*
 TutorialKit.h
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

#import <Foundation/Foundation.h>

static NSString* const TKBlurAmount = @"TKBlurAmount";
static NSString* const TKMessage = @"TKMessage";
static NSString* const TKMessageColor = @"TKMessageColor";
static NSString* const TKMessageFont = @"TKMessageFont";
static NSString* const TKMessagePoint = @"TKMessagePoint"; // absolute 0..width, 0..height
static NSString* const TKMessageRelativePoint = @"TKMessageRelativePoint"; // relative 0..1, 0..1
static NSString* const TKHighlightView = @"TKHighlightView";
static NSString* const TKHighlightViewTag = @"TKHighlightViewTag";
static NSString* const TKHighlightPoint = @"TKHighlightPoint"; // absolute 0..width, 0..height
static NSString* const TKHighlightRelativePoint = @"TKHighlightRelativePoint";  // relative 0..1
static NSString* const TKHighlightRadius = @"TKHighlightRadius";
static NSString* const TKSwipeGestureStartPoint = @"TKSwipeGestureStartPoint";
static NSString* const TKSwipeGestureRelativeStartPoint = @"TKSwipeGestureRelativeStartPoint";
static NSString* const TKSwipeGestureEndPoint = @"TKSwipeGestureEndPoint";
static NSString* const TKSwipeGestureRelativeEndPoint = @"TKSwipeGestureRelativeEndPoint";
static NSString* const TKCompleteCallback = @"TKCompleteCallback";

@interface TutorialKit : NSObject

/** Adds a tutorial sequence to display
 
 Example:
 [self addTutorialSequence:@[
 // highlight a view and display a message
 @{
 TKMessage:@"first message",
 TKMessagePoint:[NSValue valueWithCGPoint:CGPointMake(100,100)],
 TKHighlightViewTag:1,
 TKCompleteCallback:^{ NSLog("Step 1 complete!"); }
 },
 
 // highlight a specific point in a view and display a message
 @{
 TKMessage:@"second message",
 TKMessageRelativePoint:[NSValue valueWithCGPoint:CGPointMake(0.5,0.75)],
 TKHighlightViewTag:1,
 TKHighlightRelativePoint:[NSValue valueWithCGPoint:CGPointMake(0.5,0.5)],
 TKHighlightRadius:@(100)
 TKCompleteCallback:^{ NSLog("Sequence complete!"); }
 },
 
 ]];
 
 
 @param array of tutorial sequence dictionaries
 @param name The name of this tutorial sequence
 */
+ (void)addTutorialSequence:(NSArray *)sequence name:(NSString*)name;

/** Advance the tutorial sequence is possible and does not auto-continue
 
 @param name The name of the tutorial sequence to advance
 @return Returns TRUE if the tutorial sequence advanced
 */
+ (BOOL)advanceTutorialSequenceWithName:(NSString *)name;

/** Advance the tutorial sequence is possible
 
 @param name The name of the tutorial sequence to advance
 @param continue True if should continue to next tutorial step if possible
 @return Returns TRUE if the tutorial sequence advanced
 */
+ (BOOL)advanceTutorialSequenceWithName:(NSString *)name
                            andContinue:(BOOL)shouldContinue;

/** Advance the tutorial sequence is possible and only if on this step and does
 not auto-continue.
 
 @param name The name of the tutorial sequence to advance
 @param step Only advance if the tutorial is on this step
 @return Returns TRUE if the tutorial sequence advanced
 */
+ (BOOL)advanceTutorialSequenceWithName:(NSString *)name
                               ifOnStep:(NSInteger)step;

/** Advance the tutorial sequence is possible and only if on this step and
 continue if requested.
 
 @param name The name of the tutorial sequence to advance
 @param step Only advance if the tutorial is on this step
 @param shouldContinue True if should continue to next tutorial step if possible
 @return Returns TRUE if the tutorial sequence advanced
 */
+ (BOOL)advanceTutorialSequenceWithName:(NSString *)name
                               ifOnStep:(NSInteger)step
                            andContinue:(BOOL)shouldContinue;

/** Current step for the specified tutorial
 
 @param name The name of the tutorial sequence
 @return Returns the current step for the specified tutorial
 */
+ (NSInteger)currentStepForTutorialWithName:(NSString *)name;


/** The UIView for the active tutorial step
 
 @return Returns the current tutorial UIView or nil if no tutorial is visible
 */
+ (UIView *)currentTutorialView;

/** Dismiss the current tutorial view
 */
+ (void)dismissCurrentTutorialView;

/** Inserts a tutorial sequence into the existince sequence
 @param array of tutorial sequence dictionaries
 @param name The name of this tutorial sequence
 @param name The name of this tutorial sequence
 @param step The step to after which to insert this sequence
 */
+ (void)insertTutorialSequence:(NSArray *)sequence name:(NSString*)name afterStep:(NSInteger)step;

/** Inserts a tutorial sequence into the existince sequence
 @param array of tutorial sequence dictionaries
 @param name The name of this tutorial sequence
 @param name The name of this tutorial sequence
 @param step The step to before which to insert this sequence
 */
+ (void)insertTutorialSequence:(NSArray *)sequence name:(NSString*)name beforeStep:(NSInteger)step;

/** Set the current step for the specified tutorial
 
 @param step The current step for the specified tutorial sequence
 @param name The name of the tutorial sequence
 */
+ (void)setCurrentStep:(NSInteger)step forTutorial:(NSString *)name;

/** Set the default blur amount.  Set to zero to disable blur
 
 @param color The amount to blur the underlying image
 */
+ (void)setDefaultBlurAmount:(CGFloat)amount;

/** Set the default message color
 
 @param color The UIColor to use for messages by default
 */
+ (void)setDefaultMessageColor:(UIColor *)color;

/** Set the default font to use
 
 @param font The UIFont to use for messages by default
 */
+ (void)setDefaultMessageFont:(UIFont *)font;

/** Set the default background tint color
 
 @param color The UIColor to use for the background tint
 */
+ (void)setDefaultTintColor:(UIColor *)color;

@end
