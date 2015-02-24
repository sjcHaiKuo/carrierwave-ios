//
//  CRVImageEditView.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 24.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVImageEditView.h"
#import "CRVImageEditSettingsView.h"

@implementation CRVImageEditView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _heightForSettingsView = 60.f;
        _heightForInfoView = 20.f;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    
    self.infoView.frame = CGRectMake(0.f, 0.f,
                                     CGRectGetWidth(rect), self.heightForInfoView);
    
    self.settingsView.frame = CGRectMake(0.f, CGRectGetHeight(rect) - self.heightForSettingsView,
                                         CGRectGetWidth(rect), self.heightForSettingsView);
}

#pragma mark - Public Methods

- (CGRect)rectForContainerView {
    return CGRectMake(0.f,
                      self.heightForInfoView,
                      CGRectGetWidth(self.bounds),
                      CGRectGetHeight(self.bounds) - self.heightForSettingsView - self.heightForInfoView);
}

#pragma mark - Accessors

- (void)setSettingsView:(CRVSettingsView *)settingsView {
    BOOL addToSubview = (_settingsView == nil);
    _settingsView = settingsView;
    if (addToSubview) [self addSubview:_settingsView];
}

- (void)setInfoView:(UIView *)infoView {
    BOOL addToSubview = (_infoView == nil);
    _infoView = infoView;
    if (addToSubview) [self addSubview:_infoView];
}

@end
