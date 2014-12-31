//
//  CRVImageCropViewController.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "CRVImageAsset.h"
#import "CRVImageCropViewController.h"

@interface CRVImageCropViewController () <UIGestureRecognizerDelegate>

@property (assign, nonatomic) CGRect cropRect;
@property (assign, nonatomic) CGAffineTransform cropTransform;

@property (assign, nonatomic) CGAffineTransform cropRotationTransform;
@property (assign, nonatomic) CGAffineTransform cropScaleTransform;
@property (assign, nonatomic) CGAffineTransform cropTranslationTransform;

@property (assign, nonatomic) CGAffineTransform initialCropRotationTransform;
@property (assign, nonatomic) CGAffineTransform initialCropScaleTransform;
@property (assign, nonatomic) CGAffineTransform initialCropTranslationTransform;

@property (strong, nonatomic) UIRotationGestureRecognizer *rotationRecognizer;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panRecognizer;

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *wrapperView;
@property (strong, nonatomic) UIView *croppingView;

@property (assign, nonatomic, readonly) CGRect croppingViewRect;

@property (assign, nonatomic, readonly) UIEdgeInsets croppingViewMinimalEdgeInsets;

- (CGFloat)aspectFillRatioWithInitialSize:(CGSize)initialSize targetSize:(CGSize)targetSize;
- (CGFloat)scaleOfAffineTransform:(CGAffineTransform)transform;
- (CGPoint)minimalTranslationForRect:(CGRect)rect1 toBeContainedInRect:(CGRect)rect2;

- (void)updateViewTransforms;
- (void)scaleWrapperViewForFullImageContainmentAnimated:(BOOL)animated;

@end

#pragma mark -

@implementation CRVImageCropViewController

#pragma mark - Object lifecycle

- (instancetype)initWithImageAsset:(CRVImageAsset *)asset {
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    self.imageAsset = asset;
    self.rotatable = YES;
    self.zoomable = YES;
    self.maximalZoom = 3.0;
    self.cropRect = CGRectZero;
    self.cropRotationTransform = CGAffineTransformIdentity;
    self.cropScaleTransform = CGAffineTransformIdentity;
    self.cropTranslationTransform = CGAffineTransformIdentity;
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

    self.wrapperView = [[UIView alloc] init];
    self.wrapperView.userInteractionEnabled = YES;
    self.wrapperView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.wrapperView];

    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = self.imageAsset.image;
    self.imageView.userInteractionEnabled = NO;
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.wrapperView addSubview:self.imageView];

    self.croppingView = [[UIView alloc] init];
    self.croppingView.userInteractionEnabled = NO;
    self.croppingView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:(CGFloat)0.2];
    [self.view addSubview:self.croppingView];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addGestureRecognizer:self.rotationRecognizer];
    [self.view addGestureRecognizer:self.pinchRecognizer];
    [self.view addGestureRecognizer:self.panRecognizer];
}

- (void)updateViewConstraints {

    [self.wrapperView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.wrapperView);
    }];

    [self.croppingView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(self.croppingViewMinimalEdgeInsets).priorityHigh();
        make.center.equalTo(self.view);
        make.height.equalTo(self.croppingView.mas_width).dividedBy(self.ratio);
    }];

    [super updateViewConstraints];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateViewTransforms];
}

- (void)updateViewTransforms {
    CGSize imageSize = self.imageAsset.image.size, targetSize = self.croppingViewRect.size;
    CGFloat imageScale = [self aspectFillRatioWithInitialSize:imageSize targetSize:targetSize];
    self.imageView.transform = CGAffineTransformMakeScale(imageScale, imageScale);
    self.wrapperView.transform = self.cropTransform;
}

- (void)scaleWrapperViewForFullImageContainmentAnimated:(BOOL)animated {
    CGRect croppingViewRect = [self.wrapperView convertRect:self.croppingView.bounds fromView:self.croppingView];
    CGRect imageViewRect = [self.wrapperView convertRect:self.imageView.bounds fromView:self.imageView];
    if (!CGRectContainsRect(imageViewRect, croppingViewRect)) {
        CGFloat scale = [self aspectFillRatioWithInitialSize:imageViewRect.size targetSize:croppingViewRect.size];
        if (scale > 1.0) {
            CGAffineTransform initialScale = self.cropScaleTransform;
            self.cropScaleTransform = CGAffineTransformScale(initialScale, scale, scale);
        }
        CGPoint translation = [self minimalTranslationForRect:imageViewRect toBeContainedInRect:croppingViewRect];
        if (translation.x != 0 && translation.y != 0) {
            CGAffineTransform initialTranslation = self.cropTranslationTransform;
            self.cropTranslationTransform = CGAffineTransformTranslate(initialTranslation, translation.x, translation.y);
        }
        void (^animationBlock)() = ^{
            [self updateViewTransforms];
        };
        if (animated) {
            UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut;
            [UIView animateWithDuration:0.3 delay:0.0 options:options animations:animationBlock completion:nil];
        } else {
            animationBlock();
        }
    }
}

#pragma mark - Gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handleRotationRecognizer:(UIRotationGestureRecognizer *)recognizer {
    if (self.rotatable) {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            self.initialCropRotationTransform = self.cropRotationTransform;
        }
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            self.cropRotationTransform = CGAffineTransformRotate(self.initialCropRotationTransform, recognizer.rotation);
            [self updateViewTransforms];
        }
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            [self scaleWrapperViewForFullImageContainmentAnimated:YES];
        }
    }
}

- (void)handlePinchRecognizer:(UIPinchGestureRecognizer *)recognizer {
    if (self.zoomable) {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            self.initialCropScaleTransform = self.cropScaleTransform;
        }
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            CGFloat targetScale = recognizer.scale * [self scaleOfAffineTransform:self.initialCropScaleTransform];
            if (targetScale <= self.maximalZoom) {
                self.cropScaleTransform = CGAffineTransformMakeScale(targetScale, targetScale);
                [self updateViewTransforms];
            }
        }
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            [self scaleWrapperViewForFullImageContainmentAnimated:YES];
        }
    }
}

- (void)handlePanRecognizer:(UIPanGestureRecognizer *)recognizer {
    if (self.zoomable) {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            self.initialCropTranslationTransform = self.cropTranslationTransform;
        }
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            CGAffineTransform initial = self.initialCropTranslationTransform;
            CGPoint translation = [recognizer translationInView:self.view];
            self.cropTranslationTransform = CGAffineTransformTranslate(initial, translation.x, translation.y);
            [self updateViewTransforms];
        }
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            [self scaleWrapperViewForFullImageContainmentAnimated:YES];
        }
    }
}

#pragma mark - Geometry

- (CGFloat)aspectFillRatioWithInitialSize:(CGSize)initialSize targetSize:(CGSize)targetSize {
    CGFloat widthRatio = targetSize.width / initialSize.width;
    CGFloat heightRatio = targetSize.height / initialSize.height;
    return MAX(widthRatio, heightRatio);
}

- (CGFloat)scaleOfAffineTransform:(CGAffineTransform)transform {
    CGFloat xScale = (CGFloat)sqrt(transform.a * transform.a + transform.c * transform.c);
    CGFloat yScale = (CGFloat)sqrt(transform.b * transform.b + transform.d * transform.d);
    return MAX(xScale, yScale);
}

- (CGPoint)minimalTranslationForRect:(CGRect)rect1 toBeContainedInRect:(CGRect)rect2 {
    CGFloat topOffset = CGRectGetMinY(rect2) - CGRectGetMinY(rect1);
    CGFloat bottomOffset = CGRectGetMaxY(rect2) - CGRectGetMaxY(rect1);
    CGFloat leftOffset = CGRectGetMinX(rect2) - CGRectGetMinX(rect1);
    CGFloat rightOffset = CGRectGetMaxX(rect2) - CGRectGetMaxX(rect1);
    CGFloat verticalOffset = 0, horizontalOffset = 0;
    verticalOffset = ABS(topOffset) < ABS(bottomOffset) ? topOffset : bottomOffset;
    horizontalOffset = ABS(leftOffset) < ABS(rightOffset) ? leftOffset : rightOffset;
    return CGPointMake(horizontalOffset, verticalOffset);
}

#pragma mark - Public properties accessors

- (void)setImageAsset:(CRVImageAsset *)imageAsset {
    if (![self.imageAsset isEqual:imageAsset]) {
        _imageAsset = imageAsset;
        self.imageView.image = self.imageAsset.image;
        if (self.ratio == 0) {
            self.ratio = self.imageAsset.image.size.width / self.imageAsset.image.size.height;
        }
        [self.view setNeedsLayout];
    }
}

- (void)setRatio:(CGFloat)ratio {
    if (self.ratio != ratio) {
        _ratio = ratio;
        if (self.ratio == 0) {
            _ratio = self.imageAsset.image.size.width / self.imageAsset.image.size.height;
        }
        [self.view setNeedsUpdateConstraints];
    }
}

#pragma mark - Private properties accessors

- (CGAffineTransform)cropTransform {
    CGAffineTransform concatinated = CGAffineTransformConcat(self.cropRotationTransform, self.cropScaleTransform);
    return CGAffineTransformConcat(concatinated, self.cropTranslationTransform);
}

- (CGRect)croppingViewRect {
    return self.croppingView.bounds;
}

- (UIEdgeInsets)croppingViewMinimalEdgeInsets {
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

- (UIRotationGestureRecognizer *)rotationRecognizer {
    if (_rotationRecognizer != nil) return _rotationRecognizer;
    UIRotationGestureRecognizer *recognizer = [[UIRotationGestureRecognizer alloc] init];
    [recognizer addTarget:self action:@selector(handleRotationRecognizer:)];
    recognizer.delegate = self;
    return _rotationRecognizer = recognizer;
}

- (UIPinchGestureRecognizer *)pinchRecognizer {
    if (_pinchRecognizer != nil) return _pinchRecognizer;
    UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] init];
    [recognizer addTarget:self action:@selector(handlePinchRecognizer:)];
    recognizer.delegate = self;
    return _pinchRecognizer = recognizer;
}

- (UIPanGestureRecognizer *)panRecognizer {
    if (_panRecognizer != nil) return _panRecognizer;
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] init];
    [recognizer addTarget:self action:@selector(handlePanRecognizer:)];
    recognizer.delegate = self;
    return _panRecognizer = recognizer;
}

@end
