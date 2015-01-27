//
//  CRVScalableBorder.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 22.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVScalableBorder.h"
#import "CRVScalableBorder+Anchors.h"

static CGFloat const crv_dashed[2] = {3 ,3};
static CGFloat const crv_dotted[2] = {1 ,3};

@implementation CRVScalableBorder

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    self.borderInset = 5.f;
    self.anchorThickness = 2.f;
    self.gridlineGap = 1.f/3.f;
    self.gridDrawingMode = CRVGridDrawingModeOnResizing;
    self.anchorsDrawingMode = CRVAnchorsDrawingModeAlways;
    self.gridStyle = CRVGridStyleContinuous;
    self.borderStyle = CRVBorderStyleContinuous;
    self.anchorsColor = [UIColor whiteColor];
    self.gridColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
    self.borderColor = [UIColor colorWithWhite:0.9f alpha:1];
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    if (!self.isResizing) CGContextClearRect(context, rect);
    
    [self drawBorderInContext:context];
    if ([self drawAnchors]) [self drawAppleStyleAnchorsInContext:context];
    if ([self drawGrid]) [self drawGridInContext:context];
    
    CGContextRestoreGState(context);
}

- (void)drawBorderInContext:(CGContextRef)context {
    
    switch (self.borderStyle) {
        case CRVBorderStyleContinuous: {
            CGContextSetLineDash(context, 0.f, NULL, 0.f);
            break;
        }
        case CRVBorderStyleDashed: {
            CGContextSetLineDash(context, 0.f, crv_dashed, 2);
            break;
        }
        case CRVBorderStyleDotted: {
            CGContextSetLineDash(context, 0.f, crv_dotted, 2);
            break;
        }
        default:
            break;
    }

    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    CGContextAddRect(context, CGRectInset(self.bounds, self.borderInset, self.borderInset));
    CGContextStrokePath(context);
}

#pragma mark - Accessors

- (void)setResizing:(BOOL)resizing {
    _resizing = resizing;
    if (!resizing) [self setNeedsDisplay];
}

- (void)setGridlineGap:(CGFloat)gridlineGap {
    _gridlineGap = MAX(MIN(1.f, gridlineGap), 0.f);
}

#pragma mark - Private Methods

- (void)drawGridInContext:(CGContextRef)context {
    
    switch (self.gridStyle) {
        case CRVGridStyleContinuous: {
            CGContextSetLineDash(context, 0.f, NULL, 0.f);
            break;
        }
        case CRVGridStyleDashed: {
            CGContextSetLineDash(context, 0.f, crv_dashed, 2);
            break;
        }
        case CRVGridStyleDotted: {
            CGContextSetLineDash(context, 0.f, crv_dotted, 2);
            break;
        }
        default:
            break;
    }
    
    CRVWorkInProgress("grid dimension doesn't depend on grid gap yet");
    
    CGFloat horizontalGap = ceil(CGRectGetWidth(self.bounds) * (CGFloat)self.gridlineGap);
    CGFloat verticalGap = ceil(CGRectGetHeight(self.bounds) * self.gridlineGap);
    CGFloat height = CGRectGetHeight(self.bounds) - self.borderInset;
    CGFloat width = CGRectGetWidth(self.bounds) - self.borderInset;
    
    CGPoint topLeft = CGPointMake(horizontalGap, self.borderInset);
    CGPoint topRight = CGPointMake(2.f * horizontalGap, self.borderInset);
    CGPoint bottomLeft = CGPointMake(horizontalGap, height);
    CGPoint bottomRight = CGPointMake(2.f * horizontalGap, height);
    CGPoint leftTop = CGPointMake(self.borderInset, verticalGap);
    CGPoint leftBottom = CGPointMake(self.borderInset, 2.f * verticalGap);
    CGPoint rightTop = CGPointMake(width, verticalGap);
    CGPoint rightBottom = CGPointMake(width, 2.f * verticalGap);
    
    CGPoint points[8] = {topLeft, bottomLeft, topRight, bottomRight, leftTop, rightTop, leftBottom, rightBottom};
    
    CGContextSetStrokeColorWithColor(context, self.gridColor.CGColor);
    CGContextSetLineWidth(context, 1.0f);
    
    for (NSInteger i = 0; i < 8; i++) {
        
        CGPoint point = points[i];
        if (i % 2) {
            CGContextAddLineToPoint(context, point.x, point.y);
        } else {
            CGContextMoveToPoint(context, point.x, point.y);
        }
    }
    
    CGContextStrokePath(context);
}

- (BOOL)drawAnchors {
    switch (self.anchorsDrawingMode) {
        case CRVAnchorsDrawingModeAlways:
            return YES;
        case CRVAnchorsDrawingModeOnResizing:
            return self.isResizing;
        case CRVAnchorsDrawingModeNever:
        default:
            return NO;
    }
}

- (BOOL)drawGrid {
    switch (self.gridDrawingMode) {
        case CRVGridDrawingModeAlways:
            return YES;
        case CRVGridDrawingModeOnResizing:
            return self.isResizing;
        case CRVGridDrawingModeNever:
        default:
            return NO;
    }
}

@end
