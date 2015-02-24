//
//  CRVTransformView.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 23.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVTransformView.h"

@implementation CRVTransformView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        self.clipsToBounds = YES;
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        _imageView.multipleTouchEnabled = YES;
        [self addSubview:_imageView];
        
        _cropView = [[CRVScalableView alloc] init];
        _cropView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1f];
        _cropView.borderView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5f];
        [self addSubview:_cropView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.imageView.frame = frame;
    
    CGRect rect = self.bounds;
    CRVTemporary("temporary always return 200x200");
    CGSize cropSize = CGSizeMake(200.f, 200.f);
    
    self.cropView.frame = CGRectMake(CGRectGetMidX(rect) - cropSize.width * .5f,
                                     CGRectGetMidY(rect) - cropSize.height * .5f,
                                     cropSize.width,
                                     cropSize.height);
    
    self.cropView.maxSize = CGSizeMake(CGRectGetWidth(rect), CGRectGetHeight(rect));
}

#pragma mark - Accessors

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    
    self.allowToUseGestures = !([view isKindOfClass:[CRVScalableBorder class]] || [view isKindOfClass:[CRVScalableView class]]);
    return view;
}

@end
