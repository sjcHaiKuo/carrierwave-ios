//
//  CRVImageEditSettingsView.m
//  Carrierwave
//
//  Created by Paweł Białecki on 12.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVFooterView.h"

@interface CRVFooterView ()

/**
 *  Triggers an action to CRVSettingsController which will post cancel message.
 */
@property (strong, nonatomic) UIButton *cancelButton;

/**
 *  Triggers an action to CRVSettingsController which will post ratio message.
 */
@property (strong, nonatomic) UIButton *ratioButton;

/**
 *  Triggers an action to CRVSettingsController which will post done message.
 */
@property (strong, nonatomic) UIButton *doneButton;

/**
 *  Triggers an action to CRVSettingsController which will post resetTransformation message.
 */
@property (strong, nonatomic) UIButton *resetTransformButton;

@end

@implementation CRVFooterView

#pragma mark - Object lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        void (^customizeButton)(UIButton *, NSString *, SEL) = ^(UIButton *button, NSString *title, SEL selector) {
            [button setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.8f]];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            [button.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
            [button setTitle:title forState:UIControlStateNormal];
            [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        };
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        customizeButton(_cancelButton, NSLocalizedString(@"Cancel", nil), @selector(cancelButtonDidClick:));
        [self addSubview:_cancelButton];
        
        _ratioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        customizeButton(_ratioButton, NSLocalizedString(@"Ratio", nil), @selector(ratioButtonDidClick:));
        [self addSubview:_ratioButton];
        
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        customizeButton(_doneButton, NSLocalizedString(@"Done", nil), @selector(doneButtonDidClick:));
        [self addSubview:_doneButton];
        
        _resetTransformButton = [UIButton buttonWithType:UIButtonTypeCustom];
        customizeButton(_resetTransformButton, NSLocalizedString(@"Reset", nil), @selector(resetTransformButtonDidClick:));
        [self addSubview:_resetTransformButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    CGFloat margin = 10.f;
    
    CGSize buttonSize = CGSizeMake((CGFloat)floor((CGRectGetWidth(rect) - 5.f * margin) / 4.f), CGRectGetHeight(rect) - 2.f * margin);
    
    void (^layoutButton)(UIButton *, CGFloat) = ^(UIButton *button, CGFloat x) {
        button.frame = CGRectMake(x, margin, buttonSize.width, buttonSize.height);
    };
    
    layoutButton(self.cancelButton, margin);
    layoutButton(self.ratioButton, CGRectGetMaxX(self.cancelButton.frame) + margin);
    layoutButton(self.resetTransformButton, CGRectGetMaxX(self.ratioButton.frame) + margin);
    layoutButton(self.doneButton, CGRectGetMaxX(self.resetTransformButton.frame) + margin);
}

#pragma mark - UIControl Actions

- (void)cancelButtonDidClick:(UIButton *)button {
    [self.messenger postCancelMessage];
}

- (void)ratioButtonDidClick:(UIButton *)button {
    [self.messenger postShowRatioSheetMessage];
}

- (void)doneButtonDidClick:(UIButton *)button {
    [self.messenger postDoneMessage];
}

- (void)resetTransformButtonDidClick:(UIButton *)button {
    [self.messenger postResetTransformationMessage];
}


@end
