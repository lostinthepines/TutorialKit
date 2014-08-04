/*
 TutorialKitView.m
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
 
 Contains modified blur code from FXBlurView
 https://github.com/nicklockwood/FXBlurView

 Copyright (C) 2013 Charcoal Design

 FXBlurView License:
 
 This software is provided 'as-is', without any express or implied warranty. 
 In no event will the authors be held liable for any damages arising from the 
 use of this software.
 
 Permission is granted to anyone to use this software for any purpose, including 
 commercial applications, and to alter it and redistribute it freely, subject to 
 the following restrictions:
 
 The origin of this software must not be misrepresented; you must not claim that 
 you wrote the original software. If you use this software in a product, an 
 acknowledgment in the product documentation would be appreciated but is not 
 required.
 Altered source versions must be plainly marked as such, and must not be 
 misrepresented as being the original software.
 This notice may not be removed or altered from any source distribution.
 */

#import "TutorialKitView.h"
#import "TutorialKit.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

#define kTKGestureAnimationDuration 1.8
#define kTKMessagePadding (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? 40.0 : 15.0)

extern UIColor *gTutorialLabelColor;
extern UIFont *gTutorialLabelFont;

@implementation UIImage (FXBlurView)

////////////////////////////////////////////////////////////////////////////////
// FROM FXBlurView (modified)
- (UIImage *)blurredImageWithRadius:(CGFloat)radius iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor
{
    //image must be nonzero size
    if (floorf(self.size.width) * floorf(self.size.height) <= 0.0f) return self;
    
    //boxsize must be an odd integer
    uint32_t boxSize = (uint32_t)(radius * self.scale);
    if (boxSize % 2 == 0) boxSize ++;
    
    //create image buffers
    CGImageRef imageRef = self.CGImage;
    vImage_Buffer buffer1, buffer2;
    buffer1.width = buffer2.width = CGImageGetWidth(imageRef);
    buffer1.height = buffer2.height = CGImageGetHeight(imageRef);
    buffer1.rowBytes = buffer2.rowBytes = CGImageGetBytesPerRow(imageRef);
    size_t bytes = buffer1.rowBytes * buffer1.height;
    buffer1.data = malloc(bytes);
    buffer2.data = malloc(bytes);
    
    //create temp buffer
    void *tempBuffer = malloc((size_t)vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, NULL, 0, 0, boxSize, boxSize,
                                                                 NULL, kvImageEdgeExtend + kvImageGetTempBufferSize));
    
    //copy image data
    CFDataRef dataSource = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
    memcpy(buffer1.data, CFDataGetBytePtr(dataSource), bytes);
    CFRelease(dataSource);
    
    for (NSUInteger i = 0; i < iterations; i++) {
        //perform blur
        vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, tempBuffer, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        
        //swap buffers
        void *temp = buffer1.data;
        buffer1.data = buffer2.data;
        buffer2.data = temp;
    }
    
    //free buffers
    free(buffer2.data);
    free(tempBuffer);
    
    //create image context from buffer
    CGContextRef ctx = CGBitmapContextCreate(buffer1.data, buffer1.width, buffer1.height,
                                             8, buffer1.rowBytes, CGImageGetColorSpace(imageRef),
                                             CGImageGetBitmapInfo(imageRef));
    
    //apply tint
    if (tintColor && CGColorGetAlpha(tintColor.CGColor) > 0.0f)
    {
//        CGContextSetFillColorWithColor(ctx, [tintColor colorWithAlphaComponent:0.5].CGColor);
//        CGContextSetBlendMode(ctx, kCGBlendModePlusLighter);
        
//        CGContextSetFillColorWithColor(ctx, tintColor.CGColor);
        // prevent going full alpha
        CGContextSetFillColorWithColor(ctx, [tintColor colorWithAlphaComponent:CGColorGetAlpha(tintColor.CGColor) * 0.9].CGColor);
        CGContextSetBlendMode(ctx, kCGBlendModeNormal);
        CGContextFillRect(ctx, CGRectMake(0, 0, buffer1.width, buffer1.height));
    }
    
    //create image from context
    imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    CGContextRelease(ctx);
    free(buffer1.data);
    return image;
}

@end

@interface TutorialKitView()
@property (nonatomic, weak) UILabel *messageLabel;
@property (nonatomic) CGPoint gestureEnd;
@property (nonatomic) CGPoint gestureStart;
@property (nonatomic) BOOL gesturePointsRelative;
@property (nonatomic) CGPoint messageCenter;
@property (nonatomic) BOOL messageCenterRelative;
@property (nonatomic) CGPoint highlightPoint;
@property (nonatomic) BOOL highlightPointRelative;
@property (nonatomic) float highlightRadius;
@property (nonatomic, weak) UIView *highlightView;
@property (nonatomic, weak) UIView *gestureView;
@property (nonatomic) BOOL updating;
@property (nonatomic) CGFloat blurRadius;
@property (nonatomic) NSInteger blurIterations;
@property (nonatomic, weak) UIImageView *blurView;
@end

@implementation TutorialKitView

////////////////////////////////////////////////////////////////////////////////
+ (instancetype) tutorialViewWithMessage:(NSString *)message
                           messageCenter:(CGPoint)messageCenter
                   messageCenterRelative:(BOOL)relativeMessageCenter
                                    font:(UIFont *)font
                                   color:(UIColor *)color
                           highlightView:(UIView *)view
                          highlightPoint:(CGPoint)point
                  highlightPointRelative:(BOOL)relativeHighlightPoint
                         highlightRadius:(float)radius
{
    TutorialKitView *tkv = [[TutorialKitView alloc]
                            initWithFrame:UIScreen.mainScreen.bounds];
    if(message && tkv.messageLabel) {
        [tkv.messageLabel setText:message];
        if(color) tkv.messageLabel.textColor = color;
        if(font) tkv.messageLabel.font = font;
    }
    tkv.messageCenterRelative = relativeMessageCenter;
    tkv.messageCenter = messageCenter;
    tkv.highlightView = view;
    tkv.highlightPoint = point;
    tkv.highlightPointRelative = relativeHighlightPoint;
    tkv.highlightRadius = radius;
    tkv.gestureView.hidden = YES;
    return tkv;
}

////////////////////////////////////////////////////////////////////////////////
+ (instancetype) tutorialViewWithMessage:(NSString *)message
                           messageCenter:(CGPoint)messageCenter
                   messageCenterRelative:(BOOL)relativeMessageCenter
                                    font:(UIFont *)font
                                   color:(UIColor *)color
                       swipeGestureStart:(CGPoint)start
                         swipeGestureEnd:(CGPoint)end
                  swipePositionsRelative:(BOOL)relativeSwipePositions
                         highlightRadius:(float)radius
{
    TutorialKitView *tkv = [[TutorialKitView alloc]
                            initWithFrame:UIScreen.mainScreen.bounds];
    if(message && tkv.messageLabel) {
        [tkv.messageLabel setText:message];
        if(color) tkv.messageLabel.textColor = color;
        if(font) tkv.messageLabel.font = font;
    }
    tkv.gesturePointsRelative = relativeSwipePositions;
    tkv.gestureStart = start;
    tkv.gestureEnd = end;
    tkv.messageCenter = messageCenter;
    tkv.messageCenterRelative = relativeMessageCenter;
    tkv.highlightPoint = CGPointMake((start.x + end.x) / 2.f, (start.y + end.y) / 2.f);
    tkv.highlightRadius = radius;
    tkv.gestureView.hidden = CGPointEqualToPoint(tkv.gestureStart, tkv.gestureEnd) && CGPointEqualToPoint(tkv.gestureStart, CGPointZero);
    tkv.gestureView.center = relativeSwipePositions ? [tkv getAbsolutePoint:start] : start;
    [tkv animateGesture];
    return tkv;
}

////////////////////////////////////////////////////////////////////////////////
+ (instancetype) tutorialViewWithDictionary:(NSDictionary *)values
{
    // display this tutorial and advance
    CGPoint msgPoint = CGPointZero;
    BOOL msgPointRelative = NO;
    if([values objectForKey:TKMessagePoint]) {
        msgPoint = [[values objectForKey:TKMessagePoint] CGPointValue];
    }
    else if([values objectForKey:TKMessageRelativePoint]) {
        msgPoint = [[values objectForKey:TKMessageRelativePoint] CGPointValue];
        msgPointRelative = YES;
    }
    
    CGPoint highlightPoint = CGPointZero;
    BOOL highlightPointRelative = NO;
    if([values objectForKey:TKHighlightPoint]) {
        highlightPoint = [[values objectForKey:TKHighlightPoint] CGPointValue];
    }
    else if([values objectForKey:TKHighlightRelativePoint]) {
        highlightPoint = [[values objectForKey:TKHighlightRelativePoint] CGPointValue];
        highlightPointRelative = YES;
    }
    
    CGFloat radius = 0.0f;
    if([values objectForKey:TKHighlightRadius]) {
        radius = [[values objectForKey:TKHighlightRadius] floatValue];
    }
    
    TutorialKitView *tkv = nil;
    if([values objectForKey:TKHighlightView]) {
        tkv = [TutorialKitView tutorialViewWithMessage:[values objectForKey:TKMessage]
                                         messageCenter:msgPoint
                                 messageCenterRelative:msgPointRelative
                                                  font:[values objectForKey:TKMessageFont]
                                                 color:[values objectForKey:TKMessageColor]
                                          highlightView:[values objectForKey:TKHighlightView]
                                         highlightPoint:highlightPoint
                                highlightPointRelative:highlightPointRelative
                                        highlightRadius:radius];
    }
    else {
        CGPoint swipeStart = CGPointZero;
        BOOL swipePointsRelative = NO;
        if([values objectForKey:TKSwipeGestureStartPoint]) {
            swipeStart = [[values objectForKey:TKSwipeGestureStartPoint] CGPointValue];
        }
        else if([values objectForKey:TKSwipeGestureRelativeStartPoint]) {
            swipeStart = [[values objectForKey:TKSwipeGestureRelativeStartPoint] CGPointValue];
            swipePointsRelative = YES;
        }
        
        CGPoint swipeEnd = CGPointZero;
        if([values objectForKey:TKSwipeGestureEndPoint]) {
            swipeEnd = [[values objectForKey:TKSwipeGestureEndPoint] CGPointValue];
        }
        else if([values objectForKey:TKSwipeGestureRelativeEndPoint]) {
            swipeEnd = [[values objectForKey:TKSwipeGestureRelativeEndPoint] CGPointValue];
            swipePointsRelative = YES;
        }
        
        
        tkv = [TutorialKitView tutorialViewWithMessage:[values objectForKey:TKMessage]
                                         messageCenter:msgPoint
                                 messageCenterRelative:msgPointRelative
                                                  font:[values objectForKey:TKMessageFont]
                                                 color:[values objectForKey:TKMessageColor]
                                     swipeGestureStart:swipeStart
                                       swipeGestureEnd:swipeEnd
                                swipePositionsRelative:swipePointsRelative
                                       highlightRadius:radius];
    }
    
    if(tkv) {
        if([values objectForKey:TKBlurAmount]) {
            tkv.blurAmount = [[values objectForKey:TKBlurAmount] floatValue];
        }
        tkv.values = values;
    }
    return tkv;
}

////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        
        self.blurAmount = 1.0;
        self.blurIterations = 3;
        self.blurRadius = 40.f;
        
        self.gestureStart = CGPointZero;
        self.gestureEnd = CGPointZero;

        self.highlightView = nil;
        
        self.sequenceName = nil;
        self.sequenceStep = 0;
        
        self.tintColor = [UIColor colorWithWhite:1.0 alpha:0.5];

        self.updating = NO;
        
        UIImageView *blur = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:blur];
        self.blurView = blur;
        
        // touch indicator
        CGFloat radius = 36.f;
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            radius = 20.f;
        }
        
        UIView *gesture = [[UIView alloc] initWithFrame:CGRectMake(0,0,radius*2,radius*2)];
        gesture.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.7];
        gesture.layer.cornerRadius = radius;
        gesture.layer.masksToBounds = YES;
        gesture.alpha = 0;
        gesture.userInteractionEnabled = NO;
        [self addSubview:gesture];
        self.gestureView = gesture;

        // create the message label and add to the view
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textColor = UIColor.blackColor;
        label.backgroundColor = UIColor.clearColor;
        label.numberOfLines = 0;
        [self addSubview:label];
        
        self.messageLabel = label;
        
        self.userInteractionEnabled = YES;
        self.exclusiveTouch = NO;
        
        // listen for orientation changes
        [NSNotificationCenter.defaultCenter
         addObserver:self
         selector:@selector(onApplicationDidChangeStatusBarOrientationNotification)
         name:UIApplicationDidChangeStatusBarOrientationNotification
         object:nil];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////
- (void)dealloc
{
    [NSNotificationCenter.defaultCenter
     removeObserver:self
     name:UIApplicationDidChangeStatusBarOrientationNotification
     object:nil];
}

////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews
{
    [self updateRotation];
    [super layoutSubviews];
    
    if(self.messageLabel && self.messageLabel.text) {
        [self.messageLabel sizeToFit];
        CGFloat maxWidth = self.frame.size.width - kTKMessagePadding * 2.f;
        if(self.messageLabel.frame.size.width > maxWidth) {
            CGSize fit = [self.messageLabel sizeThatFits:CGSizeMake(maxWidth, 99999.f)];
            self.messageLabel.frame = CGRectMake(0,0,fit.width,fit.height);
            self.messageLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        self.messageLabel.center = self.messageCenterRelative ? [self getAbsolutePoint:self.messageCenter] : self.messageCenter;
        
        // prevent aliasing
        CGRect messageFrame = self.messageLabel.frame;
        messageFrame.origin.x = floor(messageFrame.origin.x);
        messageFrame.origin.y = floor(messageFrame.origin.y);
        self.messageLabel.frame = messageFrame;
    }
    
    self.blurView.frame = self.bounds;
    
    [self updateAsynchronously:YES completion:nil];
}

////////////////////////////////////////////////////////////////////////////////
- (void)applyMaskToImage:(UIImageView *)imageView
{
    UIGraphicsBeginImageContext(imageView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIImage *maskImage = nil;
    
    if(self.highlightView) {
        CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
        CGContextFillRect(context, imageView.bounds);

        CGRect bounds = [self.highlightView.layer convertRect:self.highlightView.layer.bounds toLayer:self.layer];
        CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [self.highlightView.layer renderInContext:context];
    }
    else {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat locations[3] = { 0.0f, 0.5f, 1.0f };
        CFArrayRef colors = (__bridge CFArrayRef)@[
                                                   (__bridge id)[UIColor clearColor].CGColor,
                                                   (__bridge id)[UIColor clearColor].CGColor,
                                                   (__bridge id)[UIColor whiteColor].CGColor
                                                   ];
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace,
                                                            colors,
                                                            locations);
        CGPoint highlightPoint = self.highlightPointRelative ?
            [self getAbsolutePoint:self.highlightPoint] :
            self.highlightPoint;
        
        CGContextDrawRadialGradient(context,
                                    gradient,
                                    highlightPoint,
                                    0,
                                    highlightPoint,
                                    MAX(10,self.highlightRadius),
                                    kCGGradientDrawsAfterEndLocation);
        
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
    }
    
    maskImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    if(maskImage) {
        CALayer *layerMask = CALayer.layer;
        layerMask.frame = imageView.bounds;
        layerMask.contents = (id)maskImage.CGImage;
        imageView.layer.mask = layerMask;
    }
}

////////////////////////////////////////////////////////////////////////////////
- (void)drawTintInContext:(CGContextRef)context
{
    CGFloat red = 0, green = 0, blue = 0, alpha = 0;
    [self.tintColor getRed:&red green:&green blue:&blue alpha:&alpha];
    CGContextSetRGBFillColor(context, red, green, blue, alpha);
    CGContextFillRect(context, self.layer.bounds);
}

////////////////////////////////////////////////////////////////////////////////
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // pass through and dismiss!
    self.gestureView.hidden = YES;
    [TutorialKit dismissCurrentTutorialView];
    return nil;
}

////////////////////////////////////////////////////////////////////////////////
// FROM FXBlurView (modified)
- (NSArray *)prepareUnderlyingViewForSnapshot
{
    __strong CALayer *blurlayer = self.layer;
    __strong CALayer *underlyingLayer = self.superview.layer;
    while (blurlayer.superlayer && blurlayer.superlayer != underlyingLayer) {
        blurlayer = blurlayer.superlayer;
    }
    
    NSMutableArray *layers = [NSMutableArray array];
    NSUInteger index = [underlyingLayer.sublayers indexOfObject:blurlayer];
    if (index != NSNotFound) {
        for (NSUInteger i = index; i < [underlyingLayer.sublayers count]; i++) {
            CALayer *layer = underlyingLayer.sublayers[i];
            if (!layer.hidden) {
                layer.hidden = YES;
                [layers addObject:layer];
            }
        }
    }
    return layers;
}

////////////////////////////////////////////////////////////////////////////////
- (void)onApplicationDidChangeStatusBarOrientationNotification
{
    if(self.alpha <= 0.f) return;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self updateRotation];
        [self setNeedsLayout];
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 1.0;
        }];
    }];
}

////////////////////////////////////////////////////////////////////////////////
- (void)setBlurAmount:(CGFloat)blurAmount
{
    _blurAmount = blurAmount;
    self.blurRadius = blurAmount * 40.f;
}

////////////////////////////////////////////////////////////////////////////////
// FROM FXBlurView (modified)
- (UIImage *)snapshotOfUnderlyingView
{
    __strong CALayer *blurLayer = self.layer;
    __strong CALayer *underlyingLayer = self.superview.layer;
    CGRect bounds = blurLayer.bounds;
    
    CGFloat scale = 0.5;
    if (self.blurIterations) {
        CGFloat blockSize = 12.0f/self.blurIterations;
        scale = blockSize/MAX(blockSize * 2, self.blurRadius);
        scale = 1.0f/floorf(1.0f/scale);
    }
    
    CGSize size = bounds.size;
    if (self.contentMode == UIViewContentModeScaleToFill ||
        self.contentMode == UIViewContentModeScaleAspectFill ||
        self.contentMode == UIViewContentModeScaleAspectFit ||
        self.contentMode == UIViewContentModeRedraw) {
        //prevents edge artefacts
        size.width = floorf(size.width * scale) / scale;
        size.height = floorf(size.height * scale) / scale;
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0f && [UIScreen mainScreen].scale == 1.0f) {
        //prevents pixelation on old devices
        scale = 1.0f;
    }
    
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    if(orientation == UIInterfaceOrientationLandscapeLeft) {
        transform = CGAffineTransformRotate(transform, M_PI / 2.f);
        transform = CGAffineTransformTranslate(transform, 0, -size.width);
    } else if(orientation == UIInterfaceOrientationLandscapeRight) {
        transform = CGAffineTransformRotate(transform, -M_PI / 2.f);
        transform = CGAffineTransformTranslate(transform, -size.height, 0);
    }
    else if(orientation == UIInterfaceOrientationPortraitUpsideDown) {
        transform = CGAffineTransformRotate(transform, M_PI);
        transform = CGAffineTransformTranslate(transform, -size.width, -size.height);
    }

    UIGraphicsBeginImageContextWithOptions(size, YES, scale);

    CGContextRef context = UIGraphicsGetCurrentContext();
    if(!context) return nil;
    CGContextConcatCTM(context, transform);
    
    NSArray *hiddenViews = [self prepareUnderlyingViewForSnapshot];

    [underlyingLayer renderInContext:context];
    for (CALayer *layer in hiddenViews) {
        layer.hidden = NO;
    }
    //[self drawTintInContext:context];
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshot;
}

////////////////////////////////////////////////////////////////////////////////
- (void)animateGesture
{
    if(self.gestureView.hidden) return;
    
    self.gestureView.center = self.gesturePointsRelative ? [self getAbsolutePoint:self.gestureStart] : self.gestureStart;
    [UIView animateWithDuration:kTKGestureAnimationDuration/3.f animations:^{
        self.gestureView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kTKGestureAnimationDuration/3.f animations:^{
            self.gestureView.center = self.gesturePointsRelative ? [self getAbsolutePoint:self.gestureEnd] : self.gestureEnd;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:kTKGestureAnimationDuration/3.f animations:^{
                self.gestureView.alpha = 0;
            } completion:^(BOOL finished) {
                [self animateGesture];
            }];
        }];
    }];
}

////////////////////////////////////////////////////////////////////////////////
- (void)applyBlurImage:(UIImage *)image completion:(void (^)())completion
{
    [self.blurView setImage:image];
    [self.blurView setContentScaleFactor:image.scale];
    
    // only apply mask if we have a highlight radius or a view to highlight
    if(self.highlightRadius > 0 || self.highlightView) {
        [self applyMaskToImage:self.blurView];
    }
    
    if (completion) {
        completion();
    }
}

////////////////////////////////////////////////////////////////////////////////
- (UIImage *)blurImage:(UIImage *)snapshot
{
    return [snapshot blurredImageWithRadius:self.blurRadius
                                 iterations:self.blurIterations
                                  tintColor:self.tintColor];
}

////////////////////////////////////////////////////////////////////////////////
- (CGPoint)getAbsolutePoint:(CGPoint)relative
{
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    CGSize size = self.bounds.size;

    // swap dimensions if bounds are not updated yet
    if((orientation == UIInterfaceOrientationLandscapeLeft ||
       orientation == UIInterfaceOrientationLandscapeRight) &&
       size.height > size.width) {
        CGFloat tmp = size.width;
        size.width = size.height;
        size.height = tmp;
    }
    
    return CGPointMake(MAX(0.f,MIN(1.f,relative.x)) * size.width,
                       MAX(0.f,MIN(1.f,relative.y)) * size.height
                       );
}

////////////////////////////////////////////////////////////////////////////////
- (void)updateAsynchronously:(BOOL)async completion:(void (^)())completion
{
    if (self.blurAmount > 0.0 && !self.updating) {
        UIImage *snapshot = [self snapshotOfUnderlyingView];
        if (async) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                UIImage *blurredImage = [self blurImage:snapshot];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self applyBlurImage:blurredImage completion:completion];
                });
            });
        }
        else {
            [self applyBlurImage:[self blurImage:snapshot] completion:completion];
        }
    }
    else if (completion) {
        completion();
    }
}

////////////////////////////////////////////////////////////////////////////////
- (void)updateRotation
{
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    CGFloat angle = 0.f;
    BOOL swap = orientation == UIInterfaceOrientationLandscapeLeft ||
                orientation == UIInterfaceOrientationLandscapeRight;
    switch (orientation) {
        default:
        case UIInterfaceOrientationPortrait: angle = 0.f; break;
        case UIInterfaceOrientationPortraitUpsideDown: angle = M_PI; break;
        case UIInterfaceOrientationLandscapeLeft: angle = -M_PI/2.f; break;
        case UIInterfaceOrientationLandscapeRight: angle = M_PI/2.f; break;
    }
    self.transform = CGAffineTransformMakeRotation(angle);
    
    if(swap) {
        self.bounds = CGRectMake(0,
                                0,
                                self.superview.frame.size.height,
                                self.superview.frame.size.width);
    }
    else {
        self.frame = self.superview.frame;
    }
}

@end
