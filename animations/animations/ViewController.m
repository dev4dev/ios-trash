//
//  ViewController.m
//  animations
//
//  Created by Alex Antonyuk on 8/7/12.
//  Copyright (c) 2012 Alex Antonyuk. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ModalComposeView.h"

@interface ViewController ()
	<ModalComposeViewDelegate>

@property (nonatomic, strong) UIView* panel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	self.view.backgroundColor = [UIColor whiteColor];

	self.panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	_panel.backgroundColor = [UIColor darkGrayColor];
	_panel.layer.shadowColor = [UIColor blackColor].CGColor;
	_panel.layer.shadowOffset = CGSizeZero;
	_panel.layer.shadowOpacity = 1.0;
	_panel.layer.anchorPoint = CGPointMake(0.5, 0.5);
	_panel.layer.position = CGPointMake(70.0, 100.0);
	_panel.layer.transform = CATransform3DMakeRotation((-25 * M_PI) / 360.0, 0.0, 0.0, 1.0);
	_panel.layer.rasterizationScale = [UIScreen mainScreen].scale;
	_panel.layer.shouldRasterize = YES;
	[self.view addSubview:_panel];

	UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn.frame = CGRectMake(10.0, 300.0, 80.0, 24.0);
	[btn setTitle:@"Animate" forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(animate) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btn];

	UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	btn2.frame = CGRectMake(10.0, 340.0, 80.0, 24.0);
	[btn2 setTitle:@"Animate2" forState:UIControlStateNormal];
	[btn2 addTarget:self action:@selector(animate2) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btn2];
}

- (void)
animate
{
	[UIView animateWithDuration:0.55 delay:0.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionCurveEaseInOut animations:^{
		self.panel.layer.position = CGPointMake(320.0 - 70.0, 100.0);
		self.panel.layer.transform = CATransform3DMakeRotation((25 * M_PI) / 360.0, 0.0, 0.0, 1.0);
	} completion:nil];

	CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	scaleAnim.values = @[@(1.0), @(1.5), @(1.0)];

	CAKeyframeAnimation *colors = [CAKeyframeAnimation animationWithKeyPath:@"backgroundColor"];
	colors.values = @[(id)[UIColor greenColor].CGColor, (id)[UIColor redColor].CGColor, (id)[UIColor greenColor].CGColor];

	CAAnimationGroup* group = [CAAnimationGroup animation];
	group.animations = @[scaleAnim, colors];
	group.removedOnCompletion = NO;
	group.fillMode = kCAFillModeForwards;
	group.autoreverses = YES;
	group.duration = 0.55;
	group.repeatCount = FLT_MAX;
	[self.panel.layer addAnimation:group forKey:@"wow"];
}

- (void)
animate2
{
	ModalComposeView *compose = [[ModalComposeView alloc] initWithTitle:@"Test input"
														  okButtonTitle:@"Post"
													  cancelButtonTitle:@"Cancel"
															   delegate:self];
	[compose.okButton setBackgroundColor:[UIColor darkGrayColor]];
	[compose.okButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[compose.cancelButton setBackgroundColor:[UIColor darkGrayColor]];
	[compose.cancelButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[compose show];
}

- (void)
modalComposeViewOkButtonTapped:(ModalComposeView *)view
{
	NSLog(@"OK - %@", view.text);
}

- (void)
modalComposeViewCancelButtonTapped:(ModalComposeView *)view
{
	NSLog(@"cancel");
}

@end
