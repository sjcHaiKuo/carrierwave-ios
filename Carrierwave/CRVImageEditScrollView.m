//
//  CRVImageEditScrollView.m
//  
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "CRVImageEditGlassView.h"
#import "CRVImageEditScrollView.h"

@interface CRVImageEditScrollView () <UIScrollViewDelegate, CRVImageEditGlassViewDelegate>

@property (strong, nonatomic, readwrite) CRVImageEditGlassView *glassView;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *wrapperView;

@property (assign, nonatomic, readonly) CGFloat scaleMultiplier;

@property (assign, nonatomic, readonly) CGAffineTransform scaleTransform;

@end

#pragma mark -

@implementation CRVImageEditScrollView

#pragma mark - Object lifecycle

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image {
    self = [super initWithFrame:frame];
    if (self == nil) return nil;

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.scrollView];

    self.wrapperView = [[UIView alloc] init];
    self.wrapperView.userInteractionEnabled = NO;
    self.wrapperView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.wrapperView];

    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.userInteractionEnabled = NO;
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.wrapperView addSubview:self.imageView];

    self.glassView = [[CRVImageEditGlassView alloc] init];
    self.glassView.delegate = self;
    self.glassView.userInteractionEnabled = NO;
    self.glassView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.glassView];

    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];

    self.image = image;
    self.minimalScale = 1.0;
    self.maximalScale = 3.0;

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame image:nil];
}

#pragma mark - View lifecycle

- (void)updateConstraints {

    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [self.wrapperView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
    }];

    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.wrapperView);
        make.center.equalTo(self.wrapperView);
    }];

    [self.glassView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [super updateConstraints];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateScrollViewContentInset];
    [self updateScrollViewZoomScales];
    [self resetScrollViewZoomScale];
}

#pragma mark - Glass view management

- (void)imageEditGlassViewDidChangeGlassRect:(CRVImageEditGlassView *)glassView {
    [self setNeedsLayout];
}

#pragma mark - Scroll view management

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.wrapperView;
}

- (void)updateScrollViewContentInset {
    CGRect glassRect = [self.glassView convertGlassRectToCoordinateSpace:self];
    self.scrollView.contentInset = [self contentInsetForScrollView:self.scrollView constrainedInRect:glassRect];
}

- (void)updateScrollViewZoomScales {
    self.scrollView.minimumZoomScale = self.minimalScale * self.scaleMultiplier;
    self.scrollView.maximumZoomScale = self.maximalScale * self.scaleMultiplier;
}

- (void)resetScrollViewZoomScale {
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
}

#pragma mark - Geometry additions

- (UIEdgeInsets)contentInsetForScrollView:(UIScrollView *)scrollView constrainedInRect:(CGRect)rect {
    CGFloat top = CGRectGetMinY(rect) - CGRectGetMinY(scrollView.frame);
    CGFloat left = CGRectGetMinX(rect) - CGRectGetMinX(scrollView.frame);
    CGFloat bottom = CGRectGetMaxY(scrollView.frame) - CGRectGetMaxY(rect);
    CGFloat right = CGRectGetMaxX(scrollView.frame) - CGRectGetMaxX(rect);
    return UIEdgeInsetsMake(top, left, bottom, right);
}

- (CGRect)invertRect:(CGRect)rect inCoordinateSpace:(id<UICoordinateSpace>)coordinateSpace {
    rect.origin.y = CGRectGetHeight(coordinateSpace.bounds) - CGRectGetMinY(rect) - CGRectGetHeight(rect);
    return rect;
}

#pragma mark - Public property accessors

- (UIImage *)image {
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    self.scrollView.contentSize = image.size;
    [self updateScrollViewZoomScales];
    [self resetScrollViewZoomScale];
}

- (void)setMinimalScale:(CGFloat)minimalScale {
    if (_minimalScale != minimalScale) {
        _minimalScale = minimalScale;
        [self updateScrollViewZoomScales];
    }
}

- (void)setMaximalScale:(CGFloat)maximalScale {
    if (_maximalScale != maximalScale) {
        _maximalScale = maximalScale;
        [self updateScrollViewZoomScales];
    }
}

- (CGFloat)currentScale {
    return self.scrollView.zoomScale / self.scaleMultiplier;
}

- (void)setCurrentScale:(CGFloat)currentScale {
    self.scrollView.zoomScale = currentScale * self.scaleMultiplier;
}

- (CGAffineTransform)imageTransform {
    return self.scaleTransform;
}

- (CGRect)imageExtent {
    CGRect extentRect = [self.glassView convertGlassRectToCoordinateSpace:self.wrapperView];
    return [self invertRect:extentRect inCoordinateSpace:self.wrapperView];
}

#pragma mark - Private property accessors

- (CGFloat)scaleMultiplier {
    CGSize targetSize = [self.glassView convertGlassRectToCoordinateSpace:self].size;
    CGFloat widthRatio = targetSize.width / self.image.size.width;
    CGFloat heightRatio = targetSize.height / self.image.size.height;
    return MAX(widthRatio, heightRatio);
}

- (CGAffineTransform)scaleTransform {
    return CGAffineTransformMakeScale(self.currentScale, self.currentScale);
}

@end
