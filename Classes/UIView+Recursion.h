/*
 UIView+Recursion.h
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
#import <UIKit/UIKit.h>

@interface UIView (Recursion)

/** Find a UIView recursively.  Return TRUE from the block to recurse into subview.
 Set stop to TRUE to stop recursing and return the subview. You can also create your own Subview Detection inside the block and set the customReturnView pointer to let the method return your custom view instead of the current subview on which the block is executed.

 @param recurse The block to use to determine whether to continue recursing
 @return Returns the UIView if found or nil
 */
- (UIView*)findViewRecursively:(BOOL(^)(UIView* subview, BOOL* stop, UIView** customReturnView))recurse;

@end
