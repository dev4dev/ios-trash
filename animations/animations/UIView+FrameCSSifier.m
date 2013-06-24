//
//  UIView+FrameCSSifier.m
//  ios-stuff
//
//  Created by Alex Antonyuk on 6/20/13.
//  Copyright (c) 2013 Alex Antonyuk. All rights reserved.
//

#import "UIView+FrameCSSifier.h"
#import <objc/runtime.h>

#define k_transactionFrameKey	"transactionFrame"

@interface UIView()

@property (nonatomic, strong) NSValue *_transactionFrame;
@property (nonatomic, assign) CGRect _workFrame;

@end

@implementation UIView (FrameCSSifier)

#pragma mark - Transaction

- (NSValue *)
_transactionFrame
{
	return objc_getAssociatedObject(self, k_transactionFrameKey);
}

- (void)
set_transactionFrame:(NSValue*)_transactionFrame
{
	objc_setAssociatedObject(self, k_transactionFrameKey, _transactionFrame, OBJC_ASSOCIATION_RETAIN);
}

- (CGRect)
_workFrame
{
	NSValue *val = self._transactionFrame;
	if (val) {
		return val.CGRectValue;
	} else {
		return self.frame;
	}
}

- (void)
set_workFrame:(CGRect)_workFrame
{
	NSValue *val = self._transactionFrame;
	if (val) {
		self._transactionFrame = [NSValue valueWithCGRect:_workFrame];
	} else {
		self.frame = _workFrame;
	}
}

- (CGFloat)
top
{
	return CGRectGetMinY(self.frame);
}

- (void)
setTop:(CGFloat)top
{
	CGRect frame = self._workFrame;
	frame.origin.y = top;
	self._workFrame = frame;
}

- (CGFloat)
left
{
	return CGRectGetMinX(self.frame);
}

- (void)
setLeft:(CGFloat)left
{
	CGRect frame = self._workFrame;
	frame.origin.x = left;
	self._workFrame = frame;
}

- (CGFloat)
right
{
	return CGRectGetWidth(self.superview.bounds) - CGRectGetMaxX(self.frame);
}

- (void)
setRight:(CGFloat)right
{
	if (!self.superview) {
		NSLog(@"UIView (FrameCSSifier) [right] works only when view has superview");
	}
	CGRect frame = self._workFrame;
	frame.origin.x = CGRectGetWidth(self.superview.bounds) - right - self.width;
	self._workFrame = frame;
}

- (CGFloat)
bottom
{
	return CGRectGetHeight(self.superview.bounds) - CGRectGetMaxY(self.frame);
}

- (void)
setBottom:(CGFloat)bottom
{
	if (!self.superview) {
		NSLog(@"UIView (FrameCSSifier) [bottom] works only when view has superview");
	}
	CGRect frame = self._workFrame;
	frame.origin.y = CGRectGetHeight(self.superview.bounds) - bottom - self.height;
	self._workFrame = frame;
}

- (CGFloat)
width
{
	return CGRectGetWidth(self.bounds);
}

- (void)
setWidth:(CGFloat)width
{
	CGRect frame = self._workFrame;
	frame.size.width = width;
	self._workFrame = frame;
}

- (CGFloat)
height
{
	return CGRectGetHeight(self.bounds);
}

- (void)
setHeight:(CGFloat)height
{
	CGRect frame = self._workFrame;
	frame.size.height = height;
	self._workFrame = frame;
}

- (void)
startFrameTransaction
{
	self._transactionFrame = [NSValue valueWithCGRect:self.frame];
}

- (void)
commitFrameTransaction
{
	NSValue *val = self._transactionFrame;
	[self cancelFrameTransaction];
	if (val) {
		CGRect frame = [val CGRectValue];
		self.frame = frame;
	}
}

- (void)
cancelFrameTransaction
{
	self._transactionFrame = nil;
}

@end
