//
//  CRVImageEditScrollView.h
//  
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import CoreGraphics;
@import UIKit;

@class CRVImageEditGlassView;

@interface CRVImageEditScrollView : UIView

/**
 * Creates an image edit scroll view.
 *
 * @param frame The frame of the view.
 * @param image The image to me edited.
 *
 * @returns The initialized receiver.
 */
- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image NS_DESIGNATED_INITIALIZER;

/**
 * The image to be resized.
 */
@property (strong, nonatomic) UIImage *image;

/**
 * The glass view displayed on top of the scroll view.
 */
@property (strong, nonatomic, readonly) CRVImageEditGlassView *glassView;

/**
 * The minimal scale of the image.
 */
@property (assign, nonatomic) CGFloat minimalScale;

/**
 * The maximal scale of the image.
 */
@property (assign, nonatomic) CGFloat maximalScale;

/**
 * The current scale of the image.
 */
@property (assign, nonatomic) CGFloat currentScale;

/**
 * The transform applied to the image.
 */
@property (assign, nonatomic, readonly) CGAffineTransform imageTransform;

/**
 * The visible extent of the image.
 */
@property (assign, nonatomic, readonly) CGRect imageExtent;

@end
