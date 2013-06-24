//
//  UIView+FrameCSSifier.h
//  ios-stuff
//
//  Created by Alex Antonyuk on 6/20/13.
//  Copyright (c) 2013 Alex Antonyuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FrameCSSifier)

@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

- (void)startFrameTransaction;
- (void)commitFrameTransaction;
- (void)cancelFrameTransaction;

@end
