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

@property (assign, nonatomic) CGAffineTransform initialCropRotationTransform;
@property (assign, nonatomic) CGAffineTransform initialCropScaleTransform;

@property (strong, nonatomic) UIRotationGestureRecognizer *rotationRecognizer;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchRecognizer;

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *wrapperView;

- (CGFloat)aspectFillRatioWithInitialSize:(CGSize)initialSize targetSize:(CGSize)targetSize;

@end

#pragma mark -

@implementation CRVImageCropViewController

#pragma mark - Object lifecycle

- (instancetype)initWithImageAsset:(CRVImageAsset *)asset {
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    self.imageAsset = asset;
    self.cropRect = CGRectZero;
    self.cropRotationTransform = CGAffineTransformIdentity;
    self.cropScaleTransform = CGAffineTransformIdentity;
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
    self.wrapperView.backgroundColor = [UIColor greenColor]; CRVTemporary("For debugging purposes");
    [self.view addSubview:self.wrapperView];

    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = self.imageAsset.image;
    self.imageView.userInteractionEnabled = NO;
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.wrapperView addSubview:self.imageView];

    [self.wrapperView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.wrapperView);
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.wrapperView addGestureRecognizer:self.rotationRecognizer];
    [self.wrapperView addGestureRecognizer:self.pinchRecognizer];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGSize imageSize = self.imageAsset.image.size, targetSize = CGSizeMake(280, 160);
    CGFloat imageScale = [self aspectFillRatioWithInitialSize:imageSize targetSize:targetSize];
    self.imageView.transform = CGAffineTransformMakeScale(imageScale, imageScale);
    self.wrapperView.transform = self.cropTransform;
}

#pragma mark - Gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handleRotationRecognizer:(UIRotationGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialCropRotationTransform = self.cropRotationTransform;
    }
    self.cropRotationTransform = CGAffineTransformRotate(self.initialCropRotationTransform, recognizer.rotation);
    [self.view setNeedsLayout];
}

- (void)handlePinchRecognizer:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialCropScaleTransform = self.cropScaleTransform;
    }
    self.cropScaleTransform = CGAffineTransformScale(self.initialCropScaleTransform, recognizer.scale, recognizer.scale);
    [self.view setNeedsLayout];
}

#pragma mark - Geometry

- (CGFloat)aspectFillRatioWithInitialSize:(CGSize)initialSize targetSize:(CGSize)targetSize {
    CGFloat widthRatio = targetSize.width / initialSize.width;
    CGFloat heightRatio = targetSize.height / initialSize.height;
    return MAX(widthRatio, heightRatio);
}

#pragma mark - Property accessors

- (void)setImageAsset:(CRVImageAsset *)imageAsset {
    if (![self.imageAsset isEqual:imageAsset]) {
        _imageAsset = imageAsset;
        self.imageView.image = self.imageAsset.image;
        [self.view setNeedsLayout];
    }
}

- (CGAffineTransform)cropTransform {
    return CGAffineTransformConcat(self.cropRotationTransform, self.cropScaleTransform);
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

@end
