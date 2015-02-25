//
//  CRVGeometry.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 25.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#ifndef Carrierwave_CRVGeometry_h
#define Carrierwave_CRVGeometry_h

CG_INLINE CGPoint CGPointAddition(CGPoint point1, CGPoint point2) {
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

CG_INLINE CGRect CGRectScale(CGRect rect, CGFloat x) {
    return CGRectMake(CGRectGetMinX(rect) * x, CGRectGetMinY(rect) * x, CGRectGetWidth(rect) * x, CGRectGetHeight(rect) * x);
}

CG_INLINE CGRect CGRectMakeCenter(CGRect rect, CGFloat x, CGFloat y) {
    return CGRectMake(CGRectGetMidX(rect) - x * .5f, CGRectGetMidY(rect) - y * .5f, x, y);
}

CG_INLINE BOOL CGSizeIsNull(CGSize size) {
    return size.width == 0.f && size.height == 0.f;
}

#endif
