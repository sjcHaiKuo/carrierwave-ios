//
//  CRVImageCropViewController.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVImageCrop.h"
#import "CRVImageCropViewController.h"

@interface CRVImageCropViewController () <UIGestureRecognizerDelegate>

@property (assign, nonatomic) CRVImageCrop crop;

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UIRotationGestureRecognizer *rotationRecognizer;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchRecognizer;

+ (UIImage *)defaultCroppingControlImage;

@end

#pragma mark -

@implementation CRVImageCropViewController

#pragma mark - Object lifecycle

- (instancetype)initWithImageAsset:(CRVImageAsset *)asset {
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    self.cancellable = YES;
    self.imageAsset = asset;
    self.croppingControlImage = [[self class] defaultCroppingControlImage];
    self.maskBackgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
    self.rotatable = YES;
    self.zoomable = YES;
    self.maximalZoom = 3.0;
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithImageAsset:nil];
}

- (instancetype)init {
    return [self initWithImageAsset:nil];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.imageView addGestureRecognizer:self.rotationRecognizer];
    [self.imageView addGestureRecognizer:self.pinchRecognizer];
}

#pragma mark - Gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handleRotationRecognizer:(UIRotationGestureRecognizer *)recognizer {
    CRVTemporary("Handle rotation recognizer");
}

- (void)handlePinchRecognizer:(UIPinchGestureRecognizer *)recognizer {
    CRVTemporary("Handle pinch recognizer");
}

#pragma mark - Property accessors

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

#pragma mark - Defaults

+ (UIImage *)defaultCroppingControlImage {
    CRVWorkInProgress("Draw a default cropping control image");
    return nil;
}

@end
