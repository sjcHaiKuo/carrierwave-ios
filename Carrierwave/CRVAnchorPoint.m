//
//  CRVAnchorPoint.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 23.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVAnchorPoint.h"

static CGFloat crv_distanceBetweenTwoPoints(CGPoint point1, CGPoint point2) {
    return (CGFloat)sqrt(pow(point2.x - point1.x, 2) + pow(point2.y - point1.y, 2));
};

@interface CRVAnchorPoint ()

@property (assign, nonatomic) CGFloat multiplierX;
@property (assign, nonatomic) CGFloat multiplierY;
@property (nonatomic, assign, readwrite) CGPoint referencePoint;
@property (nonatomic, assign, readwrite) CGFloat adjustsX;
@property (nonatomic, assign, readwrite) CGFloat adjustsY;
@property (nonatomic, assign, readwrite) CGFloat adjustsH;
@property (nonatomic, assign, readwrite) CGFloat adjustsW;
@property (nonatomic, assign, readwrite) CGFloat ratioX1;
@property (nonatomic, assign, readwrite) CGFloat ratioX2;
@property (nonatomic, assign, readwrite) CGFloat ratioY1;
@property (nonatomic, assign, readwrite) CGFloat ratioY2;
@property (nonatomic, assign, readwrite) CGFloat ratioW;
@property (nonatomic, assign, readwrite) CGFloat ratioH;

@property (nonatomic, assign, readwrite) CRVAnchorPointLocation location;

@end

@implementation CRVAnchorPoint

- (instancetype)initWithLocation:(CRVAnchorPointLocation)location {
    self = [super init];
    if (self) {
        self.location = location;
        [self assignAdjustsWithLocation:location];
    }
    return self;
}

- (void)assignAdjustsWithLocation:(CRVAnchorPointLocation)location {
    
    switch (location) {
            
        case CRVAnchorPointLocationTopLeft:
            self.adjustsX = 1.f, self.adjustsY = 1.f, self.adjustsH = -1.f, self.adjustsW = 1.f, self.multiplierX = 0.f, self.multiplierY = 0.f;
            self.ratioX1 = 0.f; self.ratioX2 = 0.f; self.ratioY1 = -1.f; self.ratioY2 = 0.f; self.ratioW = 0.f; self.ratioH = 1.f;
            break;
        case CRVAnchorPointLocationMiddleLeft:
            self.adjustsX = 1.f, self.adjustsY = 0.f, self.adjustsH = 0.f, self.adjustsW = 1.f, self.multiplierX = 0.f, self.multiplierY = 0.5f;
            self.ratioX1 = -1.f; self.ratioX2 = 0.f; self.ratioY1 = -0.5f; self.ratioY2 = 0.f; self.ratioW = 0.f; self.ratioH = 1.f;
            break;
        case CRVAnchorPointLocationBottomLeft:
            self.adjustsX = 1.f, self.adjustsY = 0.f, self.adjustsH = 1.f, self.adjustsW = 1.f, self.multiplierX = 0.f, self.multiplierY = 1.f;
            self.ratioX1 = 0.f; self.ratioX2 = 0.f; self.ratioY1 = 0.f; self.ratioY2 = 0.f; self.ratioW = 0.f; self.ratioH = 1.f;
            break;
        case CRVAnchorPointLocationTopRight:
            self.adjustsX = 0.f, self.adjustsY = 1.f, self.adjustsH = -1.f, self.adjustsW = -1.f, self.multiplierX = 1.f, self.multiplierY = 0.f;
            self.ratioX1 = 0.f; self.ratioX2 = 0.f; self.ratioY1 = -1.f; self.ratioY2 = 0.f; self.ratioW = 0.f; self.ratioH = 1.f;
            break;
        case CRVAnchorPointLocationMiddleRight:
            self.adjustsX = 0.f, self.adjustsY = 0.f, self.adjustsH = 0.f, self.adjustsW = -1.f, self.multiplierX = 1.f, self.multiplierY = 0.5f;
            self.ratioX1 = 0.f; self.ratioX2 = 0.f; self.ratioY1 = -0.5f; self.ratioY2 = 0.f; self.ratioW = 0.f; self.ratioH = 1.f;
            break;
        case CRVAnchorPointLocationBottomRight:
            self.adjustsX = 0.f, self.adjustsY = 0.f, self.adjustsH = 1.f, self.adjustsW = -1.f, self.multiplierX = 1.f, self.multiplierY = 1.f;
            self.ratioX1 = 0.f; self.ratioX2 = 0.f; self.ratioY1 = 0.f; self.ratioY2 = 0.f; self.ratioW = 0.f; self.ratioH = 1.f;
            break;
        case CRVAnchorPointLocationTopMiddle:
            self.adjustsX = 0.f, self.adjustsY = 1.f, self.adjustsH = -1.f, self.adjustsW = 0.f, self.multiplierX = 0.5f, self.multiplierY = 0.f;
            self.ratioX1 = 0.f; self.ratioX2 = -0.5f; self.ratioY1 = 0.f; self.ratioY2 = -1.f; self.ratioW = 1.f; self.ratioH = 0.f;
            break;
        case CRVAnchorPointLocationBottomMiddle:
            self.adjustsX = 0.f, self.adjustsY = 0.f, self.adjustsH = 1.f, self.adjustsW = 0.f, self.multiplierX = 0.5f, self.multiplierY = 1.f;
            self.ratioX1 = 0.f; self.ratioX2 = -0.5f; self.ratioY1 = 0.f; self.ratioY2 = 0.f; self.ratioW = 1.f; self.ratioH = 0.f;
            break;
            
        case CRVAnchorPointLocationPointsCount:
        case CRVAnchorPointLocationCenter: default:
            self.adjustsX = 0.f, self.adjustsY = 0.f, self.adjustsH = 0.f, self.adjustsW = 0.f, self.multiplierX = 0.5f, self.multiplierY = 0.5f;
            self.ratioX1 = 0.f; self.ratioX2 = 0.f; self.ratioY1 = 0.f; self.ratioY2 = 0.f; self.ratioW = 0.f; self.ratioH = 0.f;
            break;
    }
}

- (void)setReferencePointWithSize:(CGSize)size {
    self.referencePoint = CGPointMake(size.width * self.multiplierX, size.height * self.multiplierY);
}

- (CGFloat)distanceFromReferencePointToPoint:(CGPoint)point {
    return crv_distanceBetweenTwoPoints(point, self.referencePoint);
}

- (BOOL)isHold {
    return (self.adjustsH || self.adjustsW || self.adjustsX || self.adjustsY);
}

- (NSString *)locationName {
    switch (self.location) {
        case CRVAnchorPointLocationCenter:
            return @"Center";
        case CRVAnchorPointLocationTopLeft:
            return @"Top Left";
        case CRVAnchorPointLocationMiddleLeft:
            return @"Middle Left";
        case CRVAnchorPointLocationBottomLeft:
            return @"Bottom Left";
        case CRVAnchorPointLocationTopRight:
            return @"Top Right";
        case CRVAnchorPointLocationMiddleRight:
            return @"Middle Right";
        case CRVAnchorPointLocationBottomRight:
            return @"Bottom Right";
        case CRVAnchorPointLocationTopMiddle:
            return @"Top Middle";
        case CRVAnchorPointLocationBottomMiddle:
            return @"Bottom Middle";
        case CRVAnchorPointLocationPointsCount:
            return @"count";
            
        default:
            return nil;
    }
}

@end
