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

- (instancetype)initWithLocation:(CRVAnchorPointLocation)location;

- (void)setReferencePointWithSize:(CGSize)size;

- (CGFloat)distanceFromReferencePointToPoint:(CGPoint)point;

- (BOOL)isHold;

- (NSString *)locationName;

@property (assign, nonatomic, readonly) CRVAnchorPointLocation location;
@property (assign, nonatomic, readonly) CGPoint referencePoint;
@property (assign, nonatomic, readonly) CGFloat adjustsX;
@property (assign, nonatomic, readonly) CGFloat adjustsY;
@property (assign, nonatomic, readonly) CGFloat adjustsH;
@property (assign, nonatomic, readonly) CGFloat adjustsW;

@property (assign, nonatomic, readonly) CGFloat ratioX1;
@property (assign, nonatomic, readonly) CGFloat ratioX2;
@property (assign, nonatomic, readonly) CGFloat ratioY1;
@property (assign, nonatomic, readonly) CGFloat ratioY2;
@property (assign, nonatomic, readonly) CGFloat ratioW;
@property (assign, nonatomic, readonly) CGFloat ratioH;

@end
