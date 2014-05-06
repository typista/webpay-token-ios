//
//  WPYAbstractCardField.h
//  Webpay
//
//  Created by yohei on 4/17/14.
//  Copyright (c) 2014 yohei, YasuLab. All rights reserved.
//

// This class acts as a view & a controller.

#import <UIKit/UIKit.h>


@class WPYCreditCard;
@class WPYAbstractFieldModel;

@interface WPYAbstractCardField : UIView <UITextFieldDelegate>
@property(nonatomic, strong) UITextField *textField;
@property(nonatomic, strong) UIImageView *rightView;
@property(nonatomic, strong) WPYAbstractFieldModel *model;

//designated initializer
- (instancetype)initWithFrame:(CGRect)frame card:(WPYCreditCard *)card;
- (void)setFocus:(BOOL)focus;

// methods expected to be overridden
// initialization
- (UITextField *)createTextFieldWithFrame:(CGRect)frame;
- (UIImageView *)createRightView;
- (WPYAbstractFieldModel *)createFieldModelWithCard:(WPYCreditCard *)card;

- (void)textFieldDidFocus;
- (void)textFieldDidChanged:(UITextField *)textField;
- (void)textFieldWillLoseFocus;

- (void)updateValidityView:(BOOL)valid;
@end