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
    CRVGridDrawingModeNever,
    // do not use, for count information only:
    CRVGridDrawingModesCount
};

typedef NS_ENUM(NSInteger, CRVAnchorsDrawingMode) {
    CRVAnchorsDrawingModeAlways,
    CRVAnchorsDrawingModeOnResizing,
    CRVAnchorsDrawingModeNever,
    // do not use, for count information only:
    CRVAnchorDrawingModesCount
};

typedef NS_ENUM(NSInteger, CRVGridStyle) {
    CRVGridStyleContinuous,
    CRVGridStyleDashed,
    CRVGridStyleDotted,
    // do not use, for count information only:
    CRVGridStylesCount
};

typedef NS_ENUM(NSInteger, CRVBorderStyle) {
    CRVBorderStyleContinuous,
    CRVBorderStyleDashed,
    CRVBorderStyleDotted,
    // do not use, for count information only:
    CRVBorderStylesCount
};


@interface CRVScalableBorder : UIView

/**
 *  Whether user currenly resize border. Property managed and set by CRVScalableBorder. 
 *  Do not change if it is not necessary.
 */
@property (assign, nonatomic, getter=isResizing) BOOL resizing;

#pragma mark - Grid

/**
 *  Defines behaviour of grid drawing. Default set to CRVGridDrawingModeOnResizing.
 */
@property (assign, nonatomic) CRVGridDrawingMode gridDrawingMode;

/**
 *  Style of grid line. Default set to CRVGridStyleContinuous.
 */
@property (assign, nonatomic) CRVGridStyle gridStyle;

/**
 *  Color of gridline. Default is white color with 0.5 alpha.
 */
@property (strong, nonatomic) UIColor *gridColor;

/**
 *  The thickness of grid lines. Default is 1 point.
 */
@property (assign, nonatomic) NSUInteger gridThickness;

/**
 *  Number of drawn gridlines in one direction (x axis). In second direction (y axis) number will be same. 
 *  Default value: 2 - it means 4 gridlines will be drawn: 2 horizontally and 2 vertically.
 *  Notice that big number of gridlines can affect performance.
 */
@property (assign, nonatomic) NSInteger numberOfGridlines;

#pragma mark - Border

/**
 *  The margin of border draw relative to it's superview (CRVScalableBorder). Default is 5 points.
 */
@property (assign, nonatomic) NSUInteger borderInset;

/**
 *  The thickness of border. Default is 1 point.
 */
@property (assign, nonatomic) NSUInteger borderThickness;

/**
 *  Style of border line. Default set to CRVBorderStyleContinuous.
 */
@property (assign, nonatomic) CRVBorderStyle borderStyle;

/**
 *  Color of border. Default is [UIColor colorWithWhite:0.9f alpha:1] color.
 */
@property (strong, nonatomic) UIColor *borderColor;

#pragma mark - Anchors

/**
 *  The thickness of anchors. Default is 2 points.
 */
@property (assign, nonatomic) NSUInteger anchorThickness;

/**
 *  Defines behaviour of anchors drawing. Default set to CRVAnchorsDrawingModeAlways.
 */
@property (assign, nonatomic) CRVAnchorsDrawingMode anchorsDrawingMode;

/**
 *  Color of anchors. Default is white color.
 */
@property (strong, nonatomic) UIColor *anchorsColor;

@end
