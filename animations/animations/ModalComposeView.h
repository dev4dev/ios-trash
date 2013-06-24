//
//  ModalComposeView.h
//  animations
//
//  Created by Alex Antonyuk on 6/24/13.
//  Copyright (c) 2013 Alex Antonyuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ModalComposeView;
@protocol ModalComposeViewDelegate <NSObject>

@optional
- (void)modalComposeViewOkButtonTapped:(ModalComposeView*)view;
- (void)modalComposeViewCancelButtonTapped:(ModalComposeView*)view;

@end

@interface ModalComposeView : UIView

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UIButton *okButton;
@property (nonatomic, readonly) UIButton *cancelButton;
@property (nonatomic, weak) id<ModalComposeViewDelegate> delegate;
@property (nonatomic, readonly) NSString *text;

- (instancetype)initWithTitle:(NSString*)title
				okButtonTitle:(NSString*)okButtonTitle
			cancelButtonTitle:(NSString*)cancelButtonTitle
					 delegate:(id<ModalComposeViewDelegate>)delegate;
- (void)show;
- (void)dismiss;

@end
