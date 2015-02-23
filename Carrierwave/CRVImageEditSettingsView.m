//
//  CRVImageEditToolbarView.m
//  Carrierwave
//
//  Created by Paweł Białecki on 12.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVImageEditSettingsView.h"

static const CGFloat kViewHeight = 100.f;
static const CGFloat kButtonWidth = 90.f;
static const CGFloat kButtonHeight = 44.f;

@interface CRVImageEditSettingsView ()

@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *ratioButton;
@property (strong, nonatomic) UIButton *doneButton;

@end

@implementation CRVImageEditSettingsView
@synthesize doneTriggerView;

#pragma mark - Object lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat width = screenWidth;
        self.frame = CGRectMake(0, screenHeight - kViewHeight, width, kViewHeight);
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(15,
                                                                       kViewHeight - kButtonHeight - 10,
                                                                       kButtonWidth,
                                                                       kButtonHeight)];
        [self.cancelButton setTitle: NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [self.cancelButton setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.8f]];
        [self.cancelButton addTarget:self action:@selector(onCancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        [self addSubview:self.cancelButton];
        
        self.ratioButton = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth / 2) - (kButtonWidth / 2),
                                                                      kViewHeight - kButtonHeight - 10,
                                                                      kButtonWidth,
                                                                      kButtonHeight)];
        [self.ratioButton setTitle: NSLocalizedString(@"Ratio", nil) forState:UIControlStateNormal];
        [self.ratioButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.ratioButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [self.ratioButton setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.8f]];
        [self.ratioButton addTarget:self action:@selector(onRatioButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.ratioButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        [self addSubview:self.ratioButton];
        
        self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - kButtonWidth - 15,
                                                                     kViewHeight - kButtonHeight - 10,
                                                                     kButtonWidth,
                                                                     kButtonHeight)];
        [self.doneButton setTitle: NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
        [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.doneButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [self.doneButton setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.8f]];
        [self.doneButton addTarget:self action:@selector(onDoneButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.doneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        [self addSubview:self.doneButton];
    }
    
    return self;
}

#pragma mark - Button actions

- (void)onCancelButtonTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:NSStringFromSelector([self cancelAction]) object:nil];
}

- (void)onRatioButtonTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:NSStringFromSelector([self ratioAction]) object:nil];
}

- (void)onDoneButtonTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:NSStringFromSelector([self doneAction]) object:nil];
}

#pragma mark - CRVImageEditSettingsActions

- (UIView *)doneTriggerView {
    return self.doneButton;
}

- (UIView *)ratioTriggerView {
    return self.ratioButton;
}

- (SEL)cancelAction {
    return @selector(onCancelButtonTapped);
}

- (SEL)ratioAction {
    return @selector(onRatioButtonTapped);
}

- (SEL)doneAction {
    return @selector(onDoneButtonTapped);
}

@end
