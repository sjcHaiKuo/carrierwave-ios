//
//  CRVScalableBorder.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 22.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVScalableBorder.h"

@implementation CRVScalableBorder

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    self.borderInset = 5.f;
    self.anchorThickness = 2.f;
    return self;
}

- (void)setResizing:(BOOL)resizing {
    _resizing = resizing;
    if (!resizing) [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    if (!self.isResizing) CGContextClearRect(context, rect);
    
    [self drawBorderInContext:context];
    [self drawAnchorsInContext:context];
    if (self.isResizing) {
        [self drawRuleOfThirdsLinesInContext:context];
    }
    
    CGContextRestoreGState(context);
}

- (void)drawBorderInContext:(CGContextRef)context {
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.9f alpha:1].CGColor);
    CGContextAddRect(context, CGRectInset(self.bounds, self.borderInset, self.borderInset));
    CGContextStrokePath(context);
}

- (void)drawAnchorsInContext:(CGContextRef)context {
    
    CGFloat lineWidth = MIN(self.anchorThickness, self.borderInset); //cannot be larger than border inset.
    CGFloat anchorWidth = MIN(self.borderInset * 5.f, CGRectGetWidth(self.bounds)/3.f) - self.borderInset;
    CGFloat anchorHeight = MIN(self.borderInset * 5.f, CGRectGetHeight(self.bounds)/3.f) - self.borderInset;
    
    CGColorRef aColor = [UIColor whiteColor].CGColor;
    CGContextSetFillColorWithColor(context, aColor);
    CGContextSetStrokeColorWithColor(context, aColor);
    CGContextSetLineWidth(context, lineWidth);
    
    /*top left:
       A*-------*B
        |  D    |
        |  *----*C
        |  |
       F*--*E
     */
    /*D*/CGContextMoveToPoint(context, self.borderInset, self.borderInset);
    /*C*/CGContextAddLineToPoint(context, anchorWidth, self.borderInset);
    /*B*/CGContextAddLineToPoint(context, anchorWidth, self.borderInset - lineWidth);
    /*A*/CGContextAddLineToPoint(context, self.borderInset - lineWidth, self.borderInset - lineWidth);
    /*F*/CGContextAddLineToPoint(context, self.borderInset - lineWidth, anchorHeight);
    /*E*/CGContextAddLineToPoint(context, self.borderInset, anchorHeight);
    
    /*top right:
        A*-------*B
         |    E  |
        F*----*  |
              |  |
             D*--*C
     */
    /*A*/CGContextMoveToPoint(context, CGRectGetWidth(self.bounds) - anchorWidth, self.borderInset - lineWidth);
    /*B*/CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.borderInset + lineWidth, self.borderInset - lineWidth);
    /*C*/CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.borderInset + lineWidth, anchorHeight);
    /*D*/CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.borderInset, anchorHeight);
    /*E*/CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.borderInset, self.borderInset);
    /*F*/CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - anchorWidth, self.borderInset);
    
    /*bottom right:
             B*--*C
              |  |
        F*----*  |
         |    A  |
        E*-------*D
     */
    /*A*/CGContextMoveToPoint(context, CGRectGetWidth(self.bounds) - self.borderInset, CGRectGetHeight(self.bounds) - self.borderInset);
    /*B*/CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.borderInset, CGRectGetHeight(self.bounds) - anchorHeight);
    /*C*/CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.borderInset + lineWidth, CGRectGetHeight(self.bounds) - anchorHeight);
    /*D*/CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.borderInset + lineWidth, CGRectGetHeight(self.bounds) - self.borderInset + lineWidth);
    /*E*/CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - anchorWidth, CGRectGetHeight(self.bounds) - self.borderInset + lineWidth);
    /*F*/CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - anchorWidth, CGRectGetHeight(self.bounds) - self.borderInset);
    
    /*bottom left:
         E*--*F
          |  |
          |  *----*B
          |  A    |
         D*-------*C
     */
    /*A*/CGContextMoveToPoint(context, self.borderInset, CGRectGetHeight(self.bounds) - self.borderInset);
    /*B*/CGContextAddLineToPoint(context, anchorWidth, CGRectGetHeight(self.bounds) - self.borderInset);
    /*C*/CGContextAddLineToPoint(context, anchorWidth, CGRectGetHeight(self.bounds) - self.borderInset + lineWidth);
    /*D*/CGContextAddLineToPoint(context, self.borderInset - lineWidth, CGRectGetHeight(self.bounds) - self.borderInset + lineWidth);
    /*E*/CGContextAddLineToPoint(context, self.borderInset - lineWidth, CGRectGetHeight(self.bounds) - anchorHeight);
    /*F*/CGContextAddLineToPoint(context, self.borderInset, CGRectGetHeight(self.bounds) - anchorHeight);
    
    // top middle:
    CGContextMoveToPoint(context, CGRectGetMidX(self.bounds) - anchorWidth * 0.5f, self.borderInset - lineWidth);
    CGContextAddLineToPoint(context, CGRectGetMidX(self.bounds) + anchorWidth * 0.5f, self.borderInset - lineWidth);
    CGContextAddLineToPoint(context, CGRectGetMidX(self.bounds) + anchorWidth * 0.5f, self.borderInset);
    CGContextAddLineToPoint(context, CGRectGetMidX(self.bounds) - anchorWidth * 0.5f, self.borderInset);
    
    // bottom middle
    CGContextMoveToPoint(context, CGRectGetMidX(self.bounds) - anchorWidth * 0.5f, CGRectGetHeight(self.bounds) - self.borderInset);
    CGContextAddLineToPoint(context, CGRectGetMidX(self.bounds) + anchorWidth * 0.5f, CGRectGetHeight(self.bounds) - self.borderInset);
    CGContextAddLineToPoint(context, CGRectGetMidX(self.bounds) + anchorWidth * 0.5f, CGRectGetHeight(self.bounds) - self.borderInset + lineWidth);
    CGContextAddLineToPoint(context, CGRectGetMidX(self.bounds) - anchorWidth * 0.5f, CGRectGetHeight(self.bounds) - self.borderInset + lineWidth);
    
    // left middle
    CGContextMoveToPoint(context, self.borderInset - lineWidth, CGRectGetMidY(self.bounds) - anchorHeight * 0.5f);
    CGContextAddLineToPoint(context, self.borderInset, CGRectGetMidY(self.bounds) - anchorHeight * 0.5f);
    CGContextAddLineToPoint(context, self.borderInset, CGRectGetMidY(self.bounds) + anchorHeight * 0.5f);
    CGContextAddLineToPoint(context, self.borderInset - lineWidth, CGRectGetMidY(self.bounds) + anchorHeight * 0.5f);
    
    // right middle
    CGContextMoveToPoint(context, CGRectGetWidth(self.bounds) - self.borderInset, CGRectGetMidY(self.bounds) - anchorHeight * 0.5f);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.borderInset + lineWidth, CGRectGetMidY(self.bounds) - anchorHeight * 0.5f);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.borderInset + lineWidth, CGRectGetMidY(self.bounds) + anchorHeight * 0.5f);
    CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds) - self.borderInset, CGRectGetMidY(self.bounds) + anchorHeight * 0.5f);
    
    CGContextClosePath(context);
    CGContextFillPath(context);
}

- (void)drawRuleOfThirdsLinesInContext:(CGContextRef)context {
    
    CGFloat oneThirdHorizontal = ceil(CGRectGetWidth(self.bounds)/3.f);
    CGFloat oneThirdVertical = ceil(CGRectGetHeight(self.bounds)/3.f);
    CGFloat height = CGRectGetHeight(self.bounds) - self.borderInset;
    CGFloat width = CGRectGetWidth(self.bounds) - self.borderInset;
    
    CGPoint topLeft = CGPointMake(oneThirdHorizontal, self.borderInset);
    CGPoint topRight = CGPointMake(2.f * oneThirdHorizontal, self.borderInset);
    CGPoint bottomLeft = CGPointMake(oneThirdHorizontal, height);
    CGPoint bottomRight = CGPointMake(2.f * oneThirdHorizontal, height);
    CGPoint leftTop = CGPointMake(self.borderInset, oneThirdVertical);
    CGPoint leftBottom = CGPointMake(self.borderInset, 2.f * oneThirdVertical);
    CGPoint rightTop = CGPointMake(width, oneThirdVertical);
    CGPoint rightBottom = CGPointMake(width, 2.f * oneThirdVertical);
    
    CGPoint points[8] = {topLeft, bottomLeft, topRight, bottomRight, leftTop, rightTop, leftBottom, rightBottom};
    
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.5f].CGColor);
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

@end
