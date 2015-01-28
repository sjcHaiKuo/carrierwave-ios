//
//  CRVScalableBorder.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 22.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSInteger, CRVGridDrawingMode) {
    CRVGridDrawingModeAlways,
    CRVGridDrawingModeOnResizing,
    CRVGridDrawingModeNever
};

typedef NS_ENUM(NSInteger, CRVAnchorsDrawingMode) {
    CRVAnchorsDrawingModeAlways,
    CRVAnchorsDrawingModeOnResizing,
    CRVAnchorsDrawingModeNever
};

typedef NS_ENUM(NSInteger, CRVGridStyle) {
    CRVGridStyleContinuous,
    CRVGridStyleDashed,
    CRVGridStyleDotted
};

typedef NS_ENUM(NSInteger, CRVBorderStyle) {
    CRVBorderStyleContinuous,
    CRVBorderStyleDashed,
    CRVBorderStyleDotted
};


@interface CRVScalableBorder : UIView

/**
 *  Whether user currenly resize border. Property managed and set by CRVScalableBorder. 
 *  Do not change if it is not necessary.
 */
@property (assign, nonatomic, getter=isResizing) BOOL resizing;

/**
 *  The margin of border draw relative to it's superview (CRVScalableBorder). Default: 5.0f.
 */
@property (nonatomic, assign) CGFloat borderInset;

/**
 *  The thickness of anchors. Default 2.0f.
 */
@property (nonatomic, assign) CGFloat anchorThickness;

/**
 *  Defines behaviour of grid drawing. Default set to CRVGridDrawingModeOnResizing.
 */
@property (nonatomic, assign) CRVGridDrawingMode gridDrawingMode;

/**
 *  Defines behaviour of anchors drawing. Default set to CRVAnchorsDrawingModeAlways.
 */
@property (nonatomic, assign) CRVAnchorsDrawingMode anchorsDrawingMode;

/**
 *  Style of grid line. Default set to CRVGridStyleContinuous.
 */
@property (nonatomic, assign) CRVGridStyle gridStyle;

/**
 *  Style of border line. Default set to CRVBorderStyleContinuous.
 */
@property (nonatomic, assign) CRVBorderStyle borderStyle;

/**
 *  Color of gridline. Default is white color with 0.5 alpha.
 */
@property (nonatomic, strong) UIColor *gridColor;

/**
 *  Color of anchors. Default is white color.
 */
@property (nonatomic, strong) UIColor *anchorsColor;

/**
 *  Color of border. Default is [UIColor colorWithWhite:0.9f alpha:1] color.
 */
@property (nonatomic, strong) UIColor *borderColor;


/**
 *  Gap between gridlines. Can take value from 0 to 1. Default is 0.33f which corresponds to rule of thirds.
 *  Notice that huge number of gridlines can lown down performance.
 */
@property (nonatomic, assign) CGFloat gridlineGap;

@end
