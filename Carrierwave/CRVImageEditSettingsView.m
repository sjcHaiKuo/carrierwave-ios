//
//  CRVImageEditSettingsView.m
//  Carrierwave
//
//  Created by Paweł Białecki on 12.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVImageEditSettingsView.h"

@implementation CRVImageEditSettingsView

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
        customizeButton(_cancelButton, NSLocalizedString(@"Cancel", nil), @selector(onCancelButtonTapped:));
        [self addSubview:_cancelButton];
        
        _ratioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        customizeButton(_ratioButton, NSLocalizedString(@"Ratio", nil), @selector(onRatioButtonTapped:));
        [self addSubview:_ratioButton];
        
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        customizeButton(_doneButton, NSLocalizedString(@"Done", nil), @selector(onDoneButtonTapped:));
        [self addSubview:self.doneButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    CGFloat margin = 10.f;
    
    CGSize buttonSize = CGSizeMake((CGFloat)floor((CGRectGetWidth(rect) - 4.f * margin) / 3.f), CGRectGetHeight(rect) - 2.f * margin);
    
    void (^layoutButton)(UIButton *, CGFloat) = ^(UIButton *button, CGFloat x) {
        button.frame = CGRectMake(x, margin, buttonSize.width, buttonSize.height);
    };
    
    layoutButton(self.cancelButton, margin);
    layoutButton(self.ratioButton, CGRectGetMaxX(self.cancelButton.frame) + margin);
    layoutButton(self.doneButton, CGRectGetMaxX(self.ratioButton.frame) + margin);
}

#pragma mark - UIControl Actions

- (void)onCancelButtonTapped:(UIButton *)button {
    [self performCancelAction];
}

- (void)onRatioButtonTapped:(UIButton *)button {
    [self showRatioSheet];
}

- (void)onDoneButtonTapped:(UIButton *)button {
    [self performDoneAction];
}


@end