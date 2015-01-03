//
//  CRVImageEditViewController.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "CRVImageAsset.h"
#import "CRVImageEditViewController.h"

@interface CRVImageEditViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIToolbar *bottomToolbar;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *glassView;
@property (strong, nonatomic) UIView *maskView;

@property (strong, nonatomic) UIView *imageWrapperView;
@property (strong, nonatomic) UIImageView *glassImageView;

@property (strong, nonatomic) UIImage *glassImage;
@property (assign, nonatomic) UIEdgeInsets glassImageInsets;

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

@property (strong, nonatomic, readonly) CAShapeLayer *maskViewMaskLayer;

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
    self.glassImage = [[self class] defaultGlassImage];
    self.glassImageInsets = [[self class] defaultGlassImageInsets];
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithImageAsset:nil];
}

- (instancetype)init {
    return [self initWithImageAsset:nil];
}

#pragma mark - View lifecycle

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)loadView {

    [super loadView];

    self.view.backgroundColor = [UIColor colorWithWhite:(CGFloat)0.1 alpha:1];

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.backgroundColor = [UIColor clearColor];
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

    self.maskView = [[UIView alloc] init];
    self.maskView.userInteractionEnabled = NO;
    self.maskView.backgroundColor = [self.view.backgroundColor colorWithAlphaComponent:(CGFloat)0.75];
    [self.view addSubview:self.maskView];

    self.glassView = [[UIView alloc] init];
    self.glassView.userInteractionEnabled = NO;
    self.glassView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.glassView];

    self.glassImageView = [[UIImageView alloc] init];
    self.glassImageView.image = [[self class] defaultGlassImage];
    self.glassImageView.userInteractionEnabled = NO;
    self.glassImageView.backgroundColor = [UIColor clearColor];
    [self.glassView addSubview:self.glassImageView];

    self.bottomToolbar = [[UIToolbar alloc] init];
    self.bottomToolbar.barTintColor = self.view.backgroundColor;
    self.bottomToolbar.translucent = NO;
    [self.view addSubview:self.bottomToolbar];

    [self.view setNeedsUpdateConstraints];

}

- (void)viewDidLoad {

    [super viewDidLoad];

    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
    cancelButtonItem.tintColor = [UIColor colorWithHue:0.588 saturation:0.979 brightness:0.986 alpha:1];

    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelButtonTapped:)];
    doneButtonItem.tintColor = [UIColor colorWithHue:0.124 saturation:0.710 brightness:0.963 alpha:1];

    self.bottomToolbar.items = @[
        cancelButtonItem,
        spaceButtonItem,
        doneButtonItem,
    ];

}

- (void)updateViewConstraints {

    [self.bottomToolbar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.and.right.equalTo(self.view);
    }];

    [self.maskView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.glassView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(self.glassViewEdgeInsets).priorityHigh();
        make.center.equalTo(self.view);
        make.height.equalTo(self.glassView.mas_width).dividedBy(self.imageRatio);
    }];

    [self.glassImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.glassView).with.insets(self.glassImageInsets);
    }];

    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.imageWrapperView mas_updateConstraints:^(MASConstraintMaker *make) {
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
    [self updateMaskViewLayerMask];
    [self updateScrollViewZoomScales];
    [self updateScrollViewContentSize];
    [self updateScrollViewContentInset];
}

#pragma mark - Button actions

- (void)cancelButtonTapped:(UIBarButtonItem *)sender {
    if ([self.delegate respondsToSelector:@selector(imageEditViewControllerDidCancelCropping:)]) {
        [self.delegate imageEditViewControllerDidCancelCropping:self];
    }
}

- (void)doneButtonTapped:(UIBarButtonItem *)sender {
    if ([self.delegate respondsToSelector:@selector(imageEditViewController:didFinishCroppingWithImageAsset:)]) {
        CRVImageAsset *asset = [[CRVImageAsset alloc] initWithImage:self.croppedImage];
        [self.delegate imageEditViewController:self didFinishCroppingWithImageAsset:asset];
    }
}

#pragma mark - Mask view management

- (void)updateMaskViewLayerMask {
    self.maskView.layer.mask = self.maskViewMaskLayer;
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

- (CAShapeLayer *)maskViewMaskLayer {

    CGRect boundsRect = self.maskView.bounds;
    CGRect holeRect = [self.maskView convertRect:self.glassView.bounds fromView:self.glassView];

    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(boundsRect), CGRectGetMinY(boundsRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(boundsRect), CGRectGetMaxY(boundsRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(boundsRect), CGRectGetMaxY(boundsRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(boundsRect), CGRectGetMinY(boundsRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(boundsRect), CGRectGetMinY(boundsRect))];

    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(holeRect), CGRectGetMinY(holeRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(holeRect), CGRectGetMaxY(holeRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(holeRect), CGRectGetMaxY(holeRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(holeRect), CGRectGetMinY(holeRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(holeRect), CGRectGetMinY(holeRect))];

    CAShapeLayer *layer = [CAShapeLayer layer];
    [layer setPath:maskPath.CGPath];
    [layer setFillRule:kCAFillRuleEvenOdd];
    [layer setFillColor:[UIColor blackColor].CGColor];

    return layer;

}

- (UIEdgeInsets)glassViewEdgeInsets {
    return UIEdgeInsetsMake(10, 10, 54, 10);
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

#pragma mark - Glass image

+ (UIImage *)defaultGlassImage {

    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = CGSizeMake((40 * scale), (40 * scale));
    UIEdgeInsets insets = UIEdgeInsetsMake(18, 18, 18, 18);

    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, scale, scale);

    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:(CGFloat)0.9 alpha:1].CGColor);
    CGContextSetLineWidth(context, 2);

    CGContextMoveToPoint(context, 1, 16);
    CGContextAddLineToPoint(context, 1, 1);
    CGContextAddLineToPoint(context, 16, 1);

    CGContextMoveToPoint(context, 24, 1);
    CGContextAddLineToPoint(context, 39, 1);
    CGContextAddLineToPoint(context, 39, 16);

    CGContextMoveToPoint(context, 39, 24);
    CGContextAddLineToPoint(context, 39, 39);
    CGContextAddLineToPoint(context, 24, 39);

    CGContextMoveToPoint(context, 16, 39);
    CGContextAddLineToPoint(context, 1, 39);
    CGContextAddLineToPoint(context, 1, 24);

    CGContextStrokePath(context);
    CGContextSetLineWidth(context, 1);

    CGContextAddRect(context, CGRectMake(2.5, 2.5, 35, 35));

    CGContextStrokePath(context);

    CGImageRef cgImage = CGBitmapContextCreateImage(context); UIGraphicsEndImageContext();
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:scale orientation:UIImageOrientationUp]; CFRelease(cgImage);
    return [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeTile];

}

+ (UIEdgeInsets)defaultGlassImageInsets {
    return UIEdgeInsetsMake(-2, -2, -2, -2);
}

@end
