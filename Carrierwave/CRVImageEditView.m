//
//  CRVImageEditView.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 24.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVImageEditView.h"
#import "CRVFooterView.h"

@implementation CRVImageEditView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _headerHeight = 20.f;
        _footerHeight = 60.f;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    
    self.headerView.frame = CGRectMake(0.f, 0.f,
                                       CGRectGetWidth(rect), self.headerHeight);
    
    self.footerView.frame = CGRectMake(0.f, CGRectGetHeight(rect) - self.footerHeight,
                                       CGRectGetWidth(rect), self.footerHeight);
}

#pragma mark - Public Methods

- (CGRect)rectForContainerView {
    return CGRectMake(0.f,
                      self.headerHeight,
                      CGRectGetWidth(self.bounds),
                      CGRectGetHeight(self.bounds) - self.headerHeight - self.footerHeight);
}

#pragma mark - Accessors

- (void)setFooterView:(UIView *)footerView {
    if (_footerView) {
        [_footerView removeFromSuperview];
    }
    _footerView = footerView;
    [self addSubview:_footerView];
}

- (void)setHeaderView:(UIView *)headerView {
    if (_headerView) {
        [_headerView removeFromSuperview];
    }
    _headerView = headerView;
    [self addSubview:_headerView];
}

@end
