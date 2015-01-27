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
    //do not use, for enumaration only:
    CRVAnchorPointLocationPointsCount
};

@interface CRVAnchorPoint : NSObject

- (instancetype)initWithLocation:(CRVAnchorPointLocation)location;

- (void)setReferencePointWithSize:(CGSize)size;

- (CGFloat)distanceFromReferencePointToPoint:(CGPoint)point;

- (BOOL)isHold;

- (NSString *)locationName;

@property (nonatomic, assign, readonly) CRVAnchorPointLocation location;
@property (nonatomic, assign, readonly) CGPoint referencePoint;
@property (nonatomic, assign, readonly) CGFloat adjustsX;
@property (nonatomic, assign, readonly) CGFloat adjustsY;
@property (nonatomic, assign, readonly) CGFloat adjustsH;
@property (nonatomic, assign, readonly) CGFloat adjustsW;

@property (nonatomic, assign, readonly) CGFloat ratioX1;
@property (nonatomic, assign, readonly) CGFloat ratioX2;
@property (nonatomic, assign, readonly) CGFloat ratioY1;
@property (nonatomic, assign, readonly) CGFloat ratioY2;
@property (nonatomic, assign, readonly) CGFloat ratioW;
@property (nonatomic, assign, readonly) CGFloat ratioH;

@end
