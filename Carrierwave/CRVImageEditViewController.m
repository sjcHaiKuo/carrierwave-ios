//
//  CRVImageEditViewController.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "CRVImageAsset.h"
#import "CRVImageEditViewController.h"

@interface CRVImageEditViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *imageWrapperView;
@property (strong, nonatomic) UIView *glassView;

@property (assign, nonatomic, readonly) UIEdgeInsets glassViewEdgeInsets;

@property (assign, nonatomic, readonly) CGFloat imageRatio;
@property (assign, nonatomic, readonly) CGSize imageSize;

@property (assign, nonatomic, readonly) CGFloat imageViewScale;
@property (assign, nonatomic, readonly) CGSize imageViewSize;

@property (assign, nonatomic, readonly) CGFloat scrollViewMinimalZoom;
@property (assign, nonatomic, readonly) CGFloat scrollViewMaximalZoom;
@property (assign, nonatomic, readonly) CGFloat scrollViewActualZoom;

@property (assign, nonatomic, readonly) CGRect cropRect;
@property (assign, nonatomic, readonly) CGAffineTransform cropTransform;

@property (strong, nonatomic, readonly) UIImage *croppedImage;

@end

#pragma mark -

@implementation CRVImageEditViewController

#pragma mark - Object lifecycle

- (instancetype)initWithImageAsset:(CRVImageAsset *)asset {
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    self.imageAsset = asset;
    self.maximalZoom = 3.0;
    self.preserveOriginalImageSize = NO;
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithImageAsset:nil];
}

- (instancetype)init {
    return [self initWithImageAsset:nil];
}

#pragma mark - View lifecycle

- (void)loadView {

    [super loadView];

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.scrollView];

    self.imageWrapperView = [[UIView alloc] init];
    self.imageWrapperView.userInteractionEnabled = NO;
    self.imageWrapperView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.imageWrapperView];

    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = self.imageAsset.image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.userInteractionEnabled = NO;
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.imageWrapperView addSubview:self.imageView];

    self.glassView = [[UIView alloc] init];
    self.glassView.userInteractionEnabled = NO;
    self.glassView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:(CGFloat)0.2];
    [self.view addSubview:self.glassView];

    [self.view setNeedsUpdateConstraints];

}

- (void)updateViewConstraints {

    [self.glassView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(self.glassViewEdgeInsets).priorityHigh();
        make.center.equalTo(self.view);
        make.height.equalTo(self.glassView.mas_width).dividedBy(self.imageRatio);
    }];

    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.imageWrapperView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
    }];

    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.imageWrapperView);
        make.center.equalTo(self.imageWrapperView);
    }];

    [super updateViewConstraints];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateScrollViewZoomScales];
    [self updateScrollViewContentSize];
    [self updateScrollViewContentInset];
}

#pragma mark - Scroll view management

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageWrapperView;
}

- (void)updateScrollViewZoomScales {
    [UIView performWithoutAnimation:^{
        self.scrollView.minimumZoomScale = self.scrollViewMinimalZoom;
        self.scrollView.maximumZoomScale = self.scrollViewMaximalZoom;
        self.scrollView.zoomScale = self.scrollViewMinimalZoom;
    }];
}

- (void)updateScrollViewContentSize {
    self.scrollView.contentSize = self.imageViewSize;
}

- (void)updateScrollViewContentInset {
    CGFloat top = CGRectGetMinY(self.glassView.frame) - CGRectGetMinY(self.scrollView.frame);
    CGFloat left = CGRectGetMinX(self.glassView.frame) - CGRectGetMinX(self.scrollView.frame);
    CGFloat bottom = CGRectGetMaxY(self.scrollView.frame) - CGRectGetMaxY(self.glassView.frame);
    CGFloat right = CGRectGetMaxX(self.scrollView.frame) - CGRectGetMaxX(self.glassView.frame);
    self.scrollView.contentInset = UIEdgeInsetsMake(top, left, bottom, right);
}

#pragma mark - Cropping image

- (CGRect)cropRect {
    return [self.imageView convertRect:self.glassView.bounds fromView:self.glassView];
}

- (CGAffineTransform)cropTransform {
    return CGAffineTransformMakeScale(self.scrollViewActualZoom, self.scrollViewActualZoom);
}

- (UIImage *)croppedImage {
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:self.imageAsset.image.CGImage];
    ciImage = [ciImage imageByCroppingToRect:self.cropRect];
    if (self.preserveOriginalImageSize) {
        ciImage = [ciImage imageByApplyingTransform:self.cropTransform];
    }
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:ciImage fromRect:ciImage.extent];
    UIImage *uiImage = [UIImage imageWithCGImage:cgImage];
    CFRelease(cgImage);
    return uiImage;
}

#pragma mark - Public property accessors

- (void)setImageAsset:(CRVImageAsset *)imageAsset {
    if (![self.imageAsset isEqual:imageAsset]) {
        _imageAsset = imageAsset;
        self.imageView.image = self.imageAsset.image;
        [self.view setNeedsUpdateConstraints];
    }
}

- (void)setMaximalZoom:(CGFloat)maximalZoom {
    if (self.maximalZoom != maximalZoom) {
        _maximalZoom = maximalZoom;
        [self.view setNeedsLayout];
    }
}

#pragma mark - Private property accessors

- (UIEdgeInsets)glassViewEdgeInsets {
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

- (CGFloat)imageRatio {
    return self.imageAsset.image.size.width / self.imageAsset.image.size.height;
}

- (CGSize)imageSize {
    return self.imageAsset.image.size;
}

- (CGSize)imageViewSize {
    CGFloat width = CGRectGetWidth(self.glassView.frame);
    CGFloat height = CGRectGetHeight(self.glassView.frame);
    return CGSizeMake(width, height);
}

- (CGFloat)imageViewScale {
    CGFloat widthRatio = self.imageViewSize.width / self.imageSize.width;
    CGFloat heightRatio = self.imageViewSize.height / self.imageSize.height;
    return MAX(widthRatio, heightRatio);
}

- (CGFloat)scrollViewMinimalZoom {
    return self.imageViewScale;
}

- (CGFloat)scrollViewMaximalZoom {
    return self.maximalZoom * self.imageViewScale;
}

- (CGFloat)scrollViewActualZoom {
    return self.scrollView.zoomScale / self.imageViewScale;
}

@end
