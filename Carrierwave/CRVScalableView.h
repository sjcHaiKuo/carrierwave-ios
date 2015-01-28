//
//  CRVScalableFrame.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 22.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import UIKit;
#import "CRVScalableBorder.h"

@protocol CRVScalableViewDelegate;

@interface CRVScalableView : UIView

@property (weak, nonatomic) id <CRVScalableViewDelegate> delegate;

@property (strong, nonatomic, readonly) CRVScalableBorder *borderView;

// Default is 300x300 points.
@property (assign, nonatomic) CGSize maxSize;

// Default is 50x50 points.
@property (assign, nonatomic) CGSize minSize;

@property (assign, nonatomic, getter=isRatioEnabled) BOOL ratioEnabled;

//ratio W/H. 1.0f means square. 0.0f - unconstrained
@property (assign, nonatomic) CGFloat ratio;

/**
 *  Duration of animation. Default 1.0.
 */
@property (assign, nonatomic) NSTimeInterval animationDuration;

/**
 *  Animation curve. Default is UIViewAnimationOptionCurveEaseInOut.
 */
@property (assign, nonatomic) UIViewAnimationOptions animationCurve;

/**
 *  Initial spring velocity used in animation. Default 13.0f.
 */
@property (assign, nonatomic) CGFloat springVelocity;

/**
 *  Spring damping used in animation. Default 0.9f.
 */
@property (assign, nonatomic) CGFloat springDamping;

- (void)animateToFrame:(CGRect)frame completion:(void (^)(BOOL finished))completion;

- (void)animateToSize:(CGSize)size completion:(void (^)(BOOL finished))completion;

@end

@protocol CRVScalableViewDelegate <NSObject>

@optional

- (void)scalableViewDidBeginEditing:(CRVScalableView *)userResizableView;

- (void)scalableViewDidEndEditing:(CRVScalableView *)userResizableView;

@end
