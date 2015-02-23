//
//  CRVTransformViewController.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 23.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVTransformViewController.h"
#import "CRVTransformView.h"

CRVWorkInProgress("This should be dynamically calculated");
static CGFloat const CRVMinMarginOnPan = 80.f;
static CGFloat const CRVMinPixelSizeOnZoom = 50.f;

CG_INLINE CGPoint CGPointAddition(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

CG_INLINE CGRect CGRectScale(CGRect rect, CGFloat x) {
    return CGRectMake(CGRectGetMinX(rect) * x , CGRectGetMinY(rect) * x, CGRectGetWidth(rect) * x, CGRectGetHeight(rect) * x);
}

@interface CRVTransformViewController () <UIGestureRecognizerDelegate, CRVScalableViewHitTestDelegate>

@property (weak, nonatomic) CRVTransformView *aView;
@property (assign, nonatomic) CGFloat scale;
@property (assign, nonatomic) CGFloat previousScale;

@end

@implementation CRVTransformViewController

- (void)loadView {
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    CRVTransformView *view = [[CRVTransformView alloc] initWithFrame:rect];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    _aView = view;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scale = 1.f;
    
    void (^configureGesture)(UIGestureRecognizer *) = ^(UIGestureRecognizer *gesture) {
        gesture.cancelsTouchesInView = NO;
        gesture.delegate = self;
    };
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    configureGesture(panGesture);
    [self.aView addGestureRecognizer:panGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureAction:)];
    configureGesture(pinchGesture);
    [self.aView addGestureRecognizer:pinchGesture];
    
    UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateGestureAction:)];
    configureGesture(rotateGesture);
    [self.aView addGestureRecognizer:rotateGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    configureGesture(tapGesture);
    tapGesture.numberOfTapsRequired = 2;
    [self.aView addGestureRecognizer:tapGesture];
    
    self.aView.cropView.hitTestDelegate = self;
}

#pragma mark - Public Methods

- (void)setImage:(UIImage *)image {
    [self.aView.imageView setImage:image];
}

- (CRVScalableView *)cropView {
    return self.aView.cropView;
}

- (UIImage *)cropImage {
    
    self.cropView.hidden = YES;
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *sourceImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGRect finalFrame = CGRectScale(self.cropView.frame, screenScale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([sourceImage CGImage], finalFrame);
    
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:sourceImage.scale orientation:sourceImage.imageOrientation];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

#pragma mark - Gesture Recognizers

- (void)rotateGestureAction:(UIRotationGestureRecognizer *)recognizer {
    
    if (!self.aView.allowToUseGestures) {
        return;
    }
    
    self.aView.imageView.transform = CGAffineTransformRotate(self.aView.imageView.transform, recognizer.rotation);
    recognizer.rotation = 0;
}

- (void)pinchGestureAction:(UIPinchGestureRecognizer *)recognizer {
    
    if (!self.aView.allowToUseGestures) {
        return;
    } else if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.previousScale = self.scale;
    }
    
    CGFloat currentScale = recognizer.scale * self.scale;
    //X axis:
    BOOL isScaledImageViewXDimensionSmallerThanAllowed = (CGRectGetWidth(self.aView.imageView.frame) * currentScale) < CRVMinPixelSizeOnZoom;
    if (isScaledImageViewXDimensionSmallerThanAllowed) {
        currentScale = CRVMinPixelSizeOnZoom / CGRectGetWidth(self.aView.imageView.frame);
    }
    //Y axis:
    BOOL isScaledImageViewYDimensionSmallerThanAllowed = (CGRectGetHeight(self.aView.imageView.frame) * currentScale) < CRVMinPixelSizeOnZoom;
    if (isScaledImageViewYDimensionSmallerThanAllowed) {
        currentScale = CRVMinPixelSizeOnZoom / CGRectGetHeight(self.aView.imageView.frame);
    }
    
    CGFloat scaleStep = currentScale / self.previousScale;
    self.aView.imageView.transform = CGAffineTransformScale(self.aView.imageView.transform, scaleStep, scaleStep);
    self.previousScale = currentScale;
    
    BOOL didGestureFail = (recognizer.state == UIGestureRecognizerStateEnded) || (recognizer.state == UIGestureRecognizerStateCancelled) || (recognizer.state == UIGestureRecognizerStateFailed);
    if (didGestureFail) {
        self.scale = currentScale;
    }
}

- (void)panGestureAction:(UIPanGestureRecognizer *)recognizer {
    
    if (!self.aView.allowToUseGestures) {
        return;
    }
    
    CGPoint translation = [recognizer translationInView:self.aView];
    
    CRVWorkInProgress("This should be calculated with rotation taken into consideration");
    BOOL willLeftEdgeMoveOutsideRightScreenEdge = (CGRectGetMaxX(self.aView.imageView.frame) + translation.x - CRVMinMarginOnPan) < CGRectGetMinX(self.aView.frame);
    BOOL willRightEdgeMoveOutsideLeftScreenEdge = (CGRectGetMinX(self.aView.imageView.frame) + translation.x + CRVMinMarginOnPan) > CGRectGetMaxX(self.aView.frame);
    
    if (willLeftEdgeMoveOutsideRightScreenEdge || willRightEdgeMoveOutsideLeftScreenEdge) {
        translation.x = 0;
    }
    
    BOOL willBottomEdgeMoveOutsideTopScreenEdge = (CGRectGetMaxY(self.aView.imageView.frame) + translation.y) - CRVMinMarginOnPan < CGRectGetMinY(self.aView.frame);
    BOOL willTopEdgeMoveOutsideBottomScreenEdge = (CGRectGetMinY(self.aView.imageView.frame) + translation.y) + CRVMinMarginOnPan > CGRectGetMaxY(self.aView.frame);
    
    if (willTopEdgeMoveOutsideBottomScreenEdge || willBottomEdgeMoveOutsideTopScreenEdge) {
        translation.y = 0;
    }
    
    // Change location
    self.aView.imageView.center = CGPointAddition(self.aView.imageView.center, translation);
    self.aView.movePoint = CGPointAddition(self.aView.movePoint, translation);
    
    [recognizer setTranslation:CGPointZero inView:self.aView];
}

- (void)tapGestureAction:(UITapGestureRecognizer *)recognizer {
    
    self.aView.cropView.active = !self.aView.cropView.active;
    
    CRVAnchorsDrawingMode drawingMode = self.aView.cropView.active ? CRVAnchorsDrawingModeAlways : CRVAnchorsDrawingModeNever;
    self.aView.cropView.borderView.anchorsDrawingMode = drawingMode;
    
    [self.aView.cropView.borderView setResizing:NO];
}

#pragma mark - CRVScalableViewHitTestDelegate Methods

- (UIView *)viewForHitTestInScalableView:(CRVScalableView *)view {
    return self.aView.imageView;
}

#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
