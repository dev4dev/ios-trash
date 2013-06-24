//
//  ModalComposeView.m
//  animations
//
//  Created by Alex Antonyuk on 6/24/13.
//  Copyright (c) 2013 Alex Antonyuk. All rights reserved.
//

#import "ModalComposeView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+FrameCSSifier.h"

@interface BackgroundView : UIView

@end

@implementation BackgroundView

- (id)
initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		self.opaque = NO;
	}

	return self;
}

- (void)
drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);

	//Gradient colours
	size_t gradLocationsNum = 2;
	CGFloat gradLocations[2] = {0.0f, 1.0f};
	CGFloat gradColors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
	CGColorSpaceRelease(colorSpace);
	//Gradient center
	CGPoint gradCenter= CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
	//Gradient radius
	float gradRadius = MIN(self.bounds.size.width , self.bounds.size.height) ;
	//Gradient draw
	CGContextDrawRadialGradient (context, gradient, gradCenter,
								 0, gradCenter, gradRadius,
								 kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(gradient);
    CGContextSetGrayFillColor(context, 0.0f, 0.8);
	UIGraphicsPopContext();
}

@end

// ----------------------------

const int width = 260.0f;
const int height = 180.0f;

@interface ModalComposeView()

@property (nonatomic, readonly) UIWindow *window;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, copy) NSString *okButtonTitle;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, copy) NSString *cancelButtonTitle;

@property (nonatomic, strong) BackgroundView *backgroundView;
@property (nonatomic, strong) UITextView *textView;

- (void)setupView;
- (UIButton*)makeButtonWithTitle:(NSString*)title;
- (void)addShadowToLayer:(CALayer*)layer;
- (void)okButtonTapped:(id)sender;
- (void)cancelButtonTapped:(id)sender;

- (void)keyboardWillShow:(NSNotification*)notification;
- (void)keyboardWillHide:(NSNotification*)notification;

- (void)tapped;

@end

@implementation ModalComposeView

- (instancetype)
initWithTitle:(NSString *)title okButtonTitle:(NSString *)okButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle delegate:(id<ModalComposeViewDelegate>)delegate
{
	if (self = [super initWithFrame:CGRectZero]) {
		_title = title;
		_okButtonTitle = okButtonTitle;
		_cancelButtonTitle = cancelButtonTitle;
		_delegate = delegate;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
		[self setupView];
	}

	return self;
}

- (void)
dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	NSLog(@"free");
}

- (UIWindow*)
window
{
	return [UIApplication sharedApplication].keyWindow;
}

- (NSString*)
text
{
	return self.textView.text;
}

- (void)
setupView
{
	self.backgroundView = [[BackgroundView alloc] initWithFrame:self.window.bounds];
	UITapGestureRecognizer *bgTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
	[self.backgroundView addGestureRecognizer:bgTapGesture];

	CGFloat x = CGRectGetMidX(self.window.bounds) - (width / 2);
	CGFloat y = CGRectGetMidY(self.window.bounds) - (height / 2);
	self.frame = CGRectMake(x, y, width, height);
	self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

	self.backgroundColor = [UIColor whiteColor];
	[self addShadowToLayer:self.layer];

	CGFloat yOffset = 0;
	if (self.title && self.title.length > 0) {
		self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 6.0, width, 14.0)];
		self.titleLabel.backgroundColor = [UIColor clearColor];
		self.titleLabel.textAlignment = NSTextAlignmentCenter;
		self.titleLabel.textColor = [UIColor grayColor];
		self.titleLabel.font = [UIFont systemFontOfSize:14.0];
		self.titleLabel.text = self.title;
		[self addSubview:self.titleLabel];
		yOffset = 18.0;
	}

	self.okButton = [self makeButtonWithTitle:self.okButtonTitle];
	[self.okButton addTarget:self action:@selector(okButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.okButton];
	self.okButton.bottom = 10.0;
	self.okButton.left = 10.0;

	self.cancelButton = [self makeButtonWithTitle:self.cancelButtonTitle];
	[self.cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.cancelButton];
	self.cancelButton.bottom = 10.0;
	self.cancelButton.right = 10.0;

	CGRect textViewFrame = CGRectInset(self.bounds, 10.0, 10.0);
	UIView *textUnderView = [[UIView alloc] initWithFrame:textViewFrame];
	textUnderView.top += yOffset;
	textUnderView.height -= 40.0 + yOffset;
	self.textView = [[UITextView alloc] initWithFrame:textUnderView.bounds];
	self.textView.contentInset = UIEdgeInsetsMake(4.0, 0.0, 4.0, 0.0);
	[textUnderView addSubview:self.textView];
	textUnderView.layer.cornerRadius = 4.0;
	textUnderView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:0.5].CGColor;
	textUnderView.layer.borderWidth = 1.0;
	[self addSubview:textUnderView];
}

- (void)
show
{
	self.backgroundView.alpha = 0.0;
	[self.window addSubview:self.backgroundView];
	[UIView animateWithDuration:0.35 animations:^{
		self.backgroundView.alpha = 1.0;
	}];

	self.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1);
	CAKeyframeAnimation *showAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	showAnim.duration = 0.35;
	showAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	showAnim.values = @[@(0.1), @(0.8), @(1.1), @(1.0)];
	showAnim.fillMode = kCAFillModeForwards;
	[self.layer addAnimation:showAnim forKey:@"show"];
	self.layer.transform = CATransform3DIdentity;

	[self.window addSubview:self];
}

- (void)
dismiss
{
	[UIView animateWithDuration:0.35 animations:^{
		self.backgroundView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[self.backgroundView removeFromSuperview];
	}];
	CAKeyframeAnimation *dismissAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	dismissAnim.duration = 0.35;
	dismissAnim.values = @[@(1.05), @(0.8), @(0.4), @(0.0)];
	dismissAnim.delegate = self;
	dismissAnim.fillMode = kCAFillModeForwards;
	dismissAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[self.layer addAnimation:dismissAnim forKey:@"dismiss"];
	self.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0);
}

- (void)
addShadowToLayer:(CALayer*)layer
{
	layer.shadowColor = [UIColor darkGrayColor].CGColor;
	layer.shadowOffset = CGSizeMake(0.0, 0.0);
	layer.shadowOpacity = 0.5;
	layer.cornerRadius = 4.0;
	layer.rasterizationScale = [UIScreen mainScreen].scale;
	layer.shouldRasterize = YES;
}

- (UIButton*)
makeButtonWithTitle:(NSString*)title
{
	CGFloat buttonWidth = width / 2 - 14.0;
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0.0, 0.0, buttonWidth, 30.0);
	[button setTitle:title forState:UIControlStateNormal];
	button.layer.cornerRadius = 4.0;
//	[self addShadowToLayer:button.layer];
	return button;
}

- (void)
tapped
{
	[self.textView resignFirstResponder];
}

#pragma mark - Delegate
- (void)
okButtonTapped:(id)sender
{
	[self.textView resignFirstResponder];
	if ([self.delegate respondsToSelector:@selector(modalComposeViewOkButtonTapped:)]) {
		[self.delegate modalComposeViewOkButtonTapped:self];
	}
	[self dismiss];
}

- (void)
cancelButtonTapped:(id)sender
{
	[self.textView resignFirstResponder];
	if ([self.delegate respondsToSelector:@selector(modalComposeViewCancelButtonTapped:)]) {
		[self.delegate modalComposeViewCancelButtonTapped:self];
	}
	[self dismiss];
}

- (void)
animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
	if (flag) {
		self.layer.opacity = 0.0;
		[self removeFromSuperview];
	}
}

#pragma mark - Notifications

- (void)
keyboardWillHide:(NSNotification *)notification
{
	NSTimeInterval duration = 0.0;
	[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];

	[UIView animateWithDuration:duration animations:^{
		self.top += 30.0;
	}];
}

- (void)
keyboardWillShow:(NSNotification *)notification
{
	NSTimeInterval duration = 0.0;
	[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];

	[UIView animateWithDuration:duration animations:^{
		self.top -= 30.0;
	}];
}

@end
