//
//  CRVScalableView+Math.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 29.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVScalableView+Math.h"

@implementation CRVScalableView (Math)

- (CGPoint)pointByUpdateTouchPointIfOutsideOfSuperview:(CGPoint)touchPoint {
    CGFloat border = self.borderView.borderInset;
    
    if (touchPoint.x < border) {
        touchPoint.x = border;
    }
    if (touchPoint.x > self.superview.bounds.size.width - border) {
        touchPoint.x = self.superview.bounds.size.width - border;
    }
    if (touchPoint.y < border) {
        touchPoint.y = border;
    }
    if (touchPoint.y > self.superview.bounds.size.height - border) {
        touchPoint.y = self.superview.bounds.size.height - border;
    }
    return touchPoint;
}

- (void)validateFramePositionWithX:(CGFloat *)x y:(CGFloat *)y width:(CGFloat *)width height:(CGFloat *)height deltaW:(CGFloat *)deltaW deltaH:(CGFloat *)deltaH {
    
    if (self.ratioEnabled) {
        if (*x < self.superview.bounds.origin.x ||
            *y < self.superview.bounds.origin.y ||
            *x + *width > self.superview.bounds.origin.x + self.superview.bounds.size.width ||
            *y + *height > self.superview.bounds.origin.y + self.superview.bounds.size.height) {
            
            *height = self.frame.size.height;
            *y = self.frame.origin.y;
            *width = self.frame.size.width;
            *x = self.frame.origin.x;
        }
    } else {
        if (*x < self.superview.bounds.origin.x) {
            // Calculate how much to grow the width by such that the new X coordintae will align with the superview.
            *deltaW = self.frame.origin.x - self.superview.bounds.origin.x;
            *width = self.frame.size.width + *deltaW;
            *x = self.superview.bounds.origin.x;
        }
        if (*x + *width > self.superview.bounds.origin.x + self.superview.bounds.size.width) {
            *width = self.superview.bounds.size.width - *x;
        }
        if (*y < self.superview.bounds.origin.y) {
            // Calculate how much to grow the height by such that the new Y coordintae will align with the superview.
            *deltaH = self.frame.origin.y - self.superview.bounds.origin.y;
            *height = self.frame.size.height + *deltaH;
            *y = self.superview.bounds.origin.y;
        }
        if (*y + *height > self.superview.bounds.origin.y + self.superview.bounds.size.height) {
            *height = self.superview.bounds.size.height - *y;
        }
    }
}

- (void)validateFrameSizeWithX:(CGFloat *)x y:(CGFloat *)y width:(CGFloat *)width height:(CGFloat *)height {
    
    if (self.ratioEnabled) {
        if (*height < self.minSize.height || *height > self.maxSize.height ||
            *width < self.minSize.width || *width > self.maxSize.width) {
            
            *height = self.frame.size.height;
            *y = self.frame.origin.y;
            *width = self.frame.size.width;
            *x = self.frame.origin.x;
        }
    } else {
        if (*width < self.minSize.width || *width > self.maxSize.width) {
            *width = self.frame.size.width;
            *x = self.frame.origin.x;
        }
        if (*height < self.minSize.height || *height > self.maxSize.height) {
            *height = self.frame.size.height;
            *y = self.frame.origin.y;
        }
    }
}

- (CGRect)frameByCheckingBoundaries:(CGRect)frame {
    CGRect rect = frame;
    
    // rect cannot be wider than screen width
    if (CGRectGetWidth(rect) > CGRectGetWidth(self.superview.frame)) {
        rect.size.width = CGRectGetWidth(self.superview.frame);
    }
    // rect cannot be higher than screen height
    if (CGRectGetHeight(rect) > CGRectGetHeight(self.superview.frame)) {
        rect.size.height = CGRectGetHeight(self.superview.frame);
    }
    // left edge cannot go outside left screen edge
    if (CGRectGetMinX(rect) < 0.f) {
        rect.origin.x = 0.f;
    }
    // top edge cannot go outside top screen edge
    if (CGRectGetMinY(rect) < 0.f) {
        rect.origin.y = 0.f;
    }
    // right edge cannot go outside right screen edge
    if (CGRectGetMaxX(rect) > CGRectGetMaxX(self.superview.bounds)) {
        rect.origin.x -= CGRectGetMaxX(frame) - CGRectGetWidth(self.superview.bounds);
    }
    // bottom edge cannot go outside bottom screen edge
    if (CGRectGetMaxY(rect) > CGRectGetMaxY(self.superview.bounds)) {
        rect.origin.y -= CGRectGetMaxY(frame) - CGRectGetHeight(self.superview.bounds);
    }
    return rect;
}

- (CGPoint)centerWithTouchLocation:(CGPoint)touchPoint touchStart:(CGPoint)touchStart {
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - touchStart.x, self.center.y + touchPoint.y - touchStart.y);
    
    // Ensure the translation won't cause the view to move offscreen.
    CGFloat midPointX = CGRectGetMidX(self.bounds);
    if (newCenter.x > self.superview.bounds.size.width - midPointX) {
        newCenter.x = self.superview.bounds.size.width - midPointX;
    }
    if (newCenter.x < midPointX) {
        newCenter.x = midPointX;
    }
    CGFloat midPointY = CGRectGetMidY(self.bounds);
    if (newCenter.y > self.superview.bounds.size.height - midPointY) {
        newCenter.y = self.superview.bounds.size.height - midPointY;
    }
    if (newCenter.y < midPointY) {
        newCenter.y = midPointY;
    }
    return newCenter;
}

- (CGFloat)widthFromValue:(CGFloat)value {
    if (value > self.maxSize.width || value < self.minSize.width) {
        NSLog(@"Given width exceeds min/max width.\nChanged given width to proper one.");
        return MAX(MIN(value, self.maxSize.width), self.minSize.width);
    }
    return value;
}

- (CGFloat)heightFromValue:(CGFloat)value {
    if (value > self.maxSize.height || value < self.minSize.height) {
        NSLog(@"Given height exceeds min/max height.\nChanged given height to proper one.");
        return MAX(MIN(value, self.maxSize.height), self.minSize.height);
    }
    return value;
}

@end
