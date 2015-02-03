//
//  CRVAnchorPoint.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 23.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;
@import UIKit;

typedef NS_ENUM(NSInteger, CRVAnchorPointLocation) {
    CRVAnchorPointLocationCenter,
    CRVAnchorPointLocationTopLeft,
    CRVAnchorPointLocationMiddleLeft,
    CRVAnchorPointLocationBottomLeft,
    CRVAnchorPointLocationTopRight,
    CRVAnchorPointLocationMiddleRight,
    CRVAnchorPointLocationBottomRight,
    CRVAnchorPointLocationTopMiddle,
    CRVAnchorPointLocationBottomMiddle,
    //do not use, for enumeration only:
    CRVAnchorPointLocationPointsCount
};

@interface CRVAnchorPoint : NSObject

/**
 *  Initialize anchor with specified location. Designed initializer for class.
 *
 *  @param location The location where anchor should take a place.
 *
 *  @return Instance of CRVAnchorPoint class.
 */
- (instancetype)initWithLocation:(CRVAnchorPointLocation)location NS_DESIGNATED_INITIALIZER;

/**
 *  Sets reference point calculated on basis of superview size.
 *
 *  @param size The size of superview.
 */
- (void)setReferencePointWithSize:(CGSize)size;

/**
 *  Measures distance between two points and return it.
 *
 *  @param point The point from which the distance is calculated.
 *
 *  @return Distance between reference point and given point.
 */
- (CGFloat)distanceFromReferencePointToPoint:(CGPoint)point;

/**
 *  Indicates whether border is stretched.
 */
- (BOOL)isStretched;

/**
 *  Helper method which returns name of anchor location based on location enum.
 *
 *  @return Location name.
 */
- (NSString *)locationName;

/**
 *  Location of anchor.
 */
@property (assign, nonatomic, readonly) CRVAnchorPointLocation location;

#pragma Scaling factors:

@property (assign, nonatomic, readonly) CGPoint referencePoint;
@property (assign, nonatomic, readonly) CGFloat adjustsX;
@property (assign, nonatomic, readonly) CGFloat adjustsY;
@property (assign, nonatomic, readonly) CGFloat adjustsH;
@property (assign, nonatomic, readonly) CGFloat adjustsW;

#pragma Ratio factors:

@property (assign, nonatomic, readonly) CGFloat ratioX1;
@property (assign, nonatomic, readonly) CGFloat ratioX2;
@property (assign, nonatomic, readonly) CGFloat ratioY1;
@property (assign, nonatomic, readonly) CGFloat ratioY2;
@property (assign, nonatomic, readonly) CGFloat ratioW;
@property (assign, nonatomic, readonly) CGFloat ratioH;

@end
