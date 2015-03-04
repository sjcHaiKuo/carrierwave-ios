//
//  CRVTransformView.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 23.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVTransformView.h"
#import "CRVGeometry.h"

@implementation CRVTransformView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        self.clipsToBounds = YES;
        
        _imageView = [[UIImageView alloc] init];
        _imageView.accessibilityLabel = @"Crop Image View";
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        _imageView.multipleTouchEnabled = YES;
        [self addSubview:_imageView];
        
        _cropView = [[CRVScalableView alloc] initWithUnderneathView:_imageView];
        _cropView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1f];
        _cropView.borderView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5f];
        [self addSubview:_cropView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGRect rect = self.bounds;
    self.imageView.frame = rect;
    
    if (CGSizeIsNull(self.cropView.frame.size)) {
        self.cropView.frame = CGRectMake(0.f, 0.f, 200.f, 200.f);
    }
    
    CGFloat width = CGRectGetWidth(self.cropView.frame);
    CGFloat height = CGRectGetHeight(self.cropView.frame);
    
    BOOL isCropViewWidthLargerThanFrameWidth = width > CGRectGetWidth(rect);
    if (isCropViewWidthLargerThanFrameWidth) {
        width = CGRectGetWidth(rect);
        height = width / [self.cropView currentRatio];
    }
    
    BOOL isCropViewHeightLargerThanFrameHeight = height > CGRectGetHeight(rect);
    if (isCropViewHeightLargerThanFrameHeight) {
        height = CGRectGetHeight(rect);
        width = height * [self.cropView currentRatio];
    }
    
    self.cropView.frame = CGRectMakeCenter(rect, width, height);
    self.cropView.maxSize = CGSizeMake(CGRectGetWidth(rect), CGRectGetHeight(rect));
}

#pragma mark - Accessors

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    
    self.allowToUseGestures = !([view isKindOfClass:[CRVScalableBorder class]] || [view isKindOfClass:[CRVScalableView class]]);
    return view;
}

@end
