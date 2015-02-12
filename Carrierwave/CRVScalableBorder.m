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

@interface CRVScalableBorder ()

@property (assign, nonatomic) NSInteger arraySize;

@end

@implementation CRVScalableBorder

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //Grid customizing:
        self.gridColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
        self.gridDrawingMode = CRVGridDrawingModeOnResizing;
        self.gridStyle = CRVGridStyleContinuous;
        self.gridThickness = 1;
        self.numberOfGridlines = 4;
        
        //Border customizing:
        self.borderColor = [UIColor colorWithWhite:0.9f alpha:1];
        self.borderStyle = CRVBorderStyleContinuous;
        self.borderDrawinMode = CRVBorderDrawingModeAlways;
        self.borderThickness = 1;
        self.borderInset = 5;
        
        //Anchors customizing:
        self.anchorsColor = [UIColor whiteColor];
        self.anchorsDrawingMode = CRVAnchorsDrawingModeAlways;
        self.anchorThickness = 2;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    if (!self.isResizing) CGContextClearRect(context, rect);
    
    if ([self.delegate respondsToSelector:@selector(drawRect:withinContext:)]) {
        [self.delegate drawRect:self.bounds withinContext:context];
    }
    
    if ([self drawBorder]) {
        [self drawBorderInContext:context];
    }
    
    if ([self drawAnchors]) {
        [self drawAppleStyleAnchorsInContext:context];
    }
    
    if ([self drawGrid]) {
        [self drawGridInContext:context];
    }
    
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

    CGContextSetLineWidth(context, self.borderThickness);
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    CGContextAddRect(context, CGRectInset(self.bounds, self.borderInset, self.borderInset));
    CGContextStrokePath(context);
}

#pragma mark - Accessors

- (void)setResizing:(BOOL)resizing {
    _resizing = resizing;
    if (!resizing) [self setNeedsDisplay];
}

- (void)setNumberOfGridlines:(NSInteger)numberOfGridlines {
    _numberOfGridlines = MAX(0, numberOfGridlines);
    self.arraySize = _numberOfGridlines * 4;
}

#pragma mark - Private Methods

- (void)drawGridInContext:(CGContextRef)context {
    
    // set line style:
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
    
    //create array of points to connect:
    CGFloat horizontalGap = (CGRectGetWidth(self.bounds) - 2.f * self.borderInset) / (self.numberOfGridlines + 1);
    CGFloat verticalGap = (CGRectGetHeight(self.bounds) - 2.f * self.borderInset) / (self.numberOfGridlines + 1);
    CGFloat height = CGRectGetHeight(self.bounds) - self.borderInset;
    CGFloat width = CGRectGetWidth(self.bounds) - self.borderInset;
    CGPoint array[self.arraySize];
    
    int helperH = 0; int helperV = 0;
    
    for (NSInteger i = 0; i < self.arraySize; i++) {
        
        if (i < self.arraySize * 0.5) { //horizontal
            
            if (i % 2) { //bottom
                array[i] = CGPointMake(horizontalGap * helperH + self.borderInset, height);
            } else { //top
                helperH++;
                array[i] = CGPointMake(horizontalGap * helperH + self.borderInset, self.borderInset);
            }
            
        } else { //vertical
            
            if (i % 2) { //right
                array[i] = CGPointMake(width, verticalGap * helperV + self.borderInset);
            } else { //left
                helperV++;
                array[i] = CGPointMake(self.borderInset, verticalGap * helperV + self.borderInset);
            }
        }
    }
    
    //draw!
    CGContextSetStrokeColorWithColor(context, self.gridColor.CGColor);
    CGContextSetLineWidth(context, self.gridThickness);
    
    for (NSInteger i = 0; i < self.arraySize; i++) {
        
        CGPoint point = array[i];
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

- (BOOL)drawBorder {
    switch (self.borderDrawinMode) {
        case CRVBorderDrawingModeAlways:
            return YES;
        case CRVBorderDrawingModeNever:
        default:
            return NO;
    }
}

@end
