//
//  CRVScalableView+Math.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 29.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Carrierwave/Carrierwave.h>

@interface CRVScalableView (Math)

/**
 *  Updates the touch point if we're outside the superview.
 */
- (CGPoint)pointByUpdateTouchPointIfOutsideOfSuperview:(CGPoint)touchPoint;

/**
 *  Calculates new size and cancel changes if new size is too small or too large.
 */
- (void)validateFrameSizeWithX:(CGFloat *)x y:(CGFloat *)y width:(CGFloat *)width height:(CGFloat *)height;

/**
 *  Calculates new frame and ensures the resize won't cause the view to move offscreen.
 */
- (void)validateFramePositionWithX:(CGFloat *)x y:(CGFloat *)y width:(CGFloat *)width height:(CGFloat *)height deltaW:(CGFloat *)deltaW deltaH:(CGFloat *)deltaH;

/**
 *  Calculates new frame and ensures that new frame will nor exceed superview bounds.
 */
- (CGRect)frameByCheckingBoundaries:(CGRect)frame;

/**
 *  Calculates new center of view and ensures the translation won't cause the view to move offscreen.
 */
- (CGPoint)centerWithTouchLocation:(CGPoint)touchPoint touchStart:(CGPoint)touchStart;

/**
 *  Ensures that given value do not exceed minimum or maximum width.
 */
- (CGFloat)widthFromValue:(CGFloat)value;

/**
 *  Ensures that given value do not exceed minimum or maximum height.
 */
- (CGFloat)heightFromValue:(CGFloat)value;

@end
