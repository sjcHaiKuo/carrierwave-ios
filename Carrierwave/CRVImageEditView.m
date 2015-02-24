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

@synthesize settingsView = _settingsView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _heightForSettingsView = 80.f;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.settingsView.frame = CGRectMake(0.f, CGRectGetHeight(self.bounds) - self.heightForSettingsView,
                                         CGRectGetWidth(self.bounds), self.heightForSettingsView);
}

#pragma mark - Public Methods

- (CGRect)rectForContainerView {
    return CGRectMake(0.f, 0.f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - self.heightForSettingsView);
}

#pragma mark - Accessors

- (UIView <CRVImageEditSettingsActions> *)settingsView {
    if (_settingsView == nil) {
        _settingsView = [[CRVImageEditSettingsView alloc] init];
        [self addSubview:_settingsView];
    }
    return _settingsView;
}

@end
