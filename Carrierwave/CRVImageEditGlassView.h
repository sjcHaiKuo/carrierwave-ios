//
//  CRVImageEditGlassView.h
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import CoreGraphics;
@import UIKit;

@protocol CRVImageEditGlassViewDelegate;

/**
 * The CRVImageEditGlassView is a view that appears over the image being edited
 * in the CRVImageEditViewController. It provides visual feedback of the target
 * crop of the image beind edited.
 */
@interface CRVImageEditGlassView : UIView

/**
 * The color of the masking view.
 */
@property (strong, nonatomic) UIColor *maskColor;

/**
 * The aspect ratio of the transparent glass (default: 1 - square).
 */
@property (assign, nonatomic) CGFloat glassRatio;

/**
 * The edge insets of the transparent glass.
 */
@property (assign, nonatomic) UIEdgeInsets glassInsets;

/**
 * The glass (a.k.a. crop control) image.
 */
@property (strong, nonatomic, readonly) UIImage *glassImage;

/**
 * The insets of the glass image.
 */
@property (assign, nonatomic, readonly) UIEdgeInsets glassImageInsets;

/**
 * The receiver's delegate object.
 */
@property (weak, nonatomic) id<CRVImageEditGlassViewDelegate> delegate;

/**
 * Sets the glass image with its insets.
 *
 * @param glassImage The glass image to be used.
 * @param glassImageInsets The glass image insets to be used.
 */
- (void)setGlassImage:(UIImage *)glassImage withInsets:(UIEdgeInsets)glassImageInsets;

/**
 * Converts the glass rect to the specified coordinate space.
 *
 * @param coordinateSpace The target coordinate space.
 *
 * @returns The converted glass rectangle.
 */
- (CGRect)convertGlassRectToCoordinateSpace:(id<UICoordinateSpace>)coordinateSpace;

@end

@protocol CRVImageEditGlassViewDelegate <NSObject> @optional

- (void)imageEditGlassViewDidChangeGlassRect:(CRVImageEditGlassView *)glassView;

@end
