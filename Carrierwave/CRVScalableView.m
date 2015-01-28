//
//  CRVScalableFrame.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 22.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//
//  Resizing mechanism made by Stephen Poletto ( http://stephenpoletto.com ). Improved by Patryk Kaczmarek.

#import "CRVScalableView.h"
#import "CRVAnchorPoint.h"

@interface CRVScalableView ()

@property (strong, nonatomic) CRVAnchorPoint *anchorPoint;
@property (assign, nonatomic) CGPoint touchStart;

@property (strong, nonatomic) NSArray *anchorPoints;

@end

@implementation CRVScalableView

#pragma mark - Object lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    _borderView = [[CRVScalableBorder alloc] initWithFrame:self.bounds];
    [self addSubview:_borderView];
    
    self.ratioEnabled = YES;
    self.ratio = 0.5f;
    self.minSize = CGSizeMake(50.f, 50.f);
    self.maxSize = CGSizeMake(320.f, 320.f);
    
    self.animationDuration = 1.0f;
    self.animationCurve = UIViewAnimationOptionCurveEaseInOut;
    self.springDamping = 0.9f;
    self.springVelocity = 13.f;
    
    self.anchorPoints = [self anchorPointsMakeArray];
    
    CRVTemporary("to see frames");
    self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    _borderView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5f];
    
    return self;
}

- (void)setFrame:(CGRect)newFrame {
    [super setFrame:newFrame];
    
    self.borderView.frame = self.bounds;
    [self.borderView setNeedsDisplay];
}

#pragma mark - Public Methods

- (void)animateToFrame:(CGRect)frame completion:(void (^)(BOOL finished))completion {
    
    CGRect rect = CGRectMake(CGRectGetMinX(frame),
                             CGRectGetMinY(frame),
                             [self trueWidthFromValue:CGRectGetWidth(frame)],
                             [self trueHeightFromValue:CGRectGetHeight(frame)]);
    
    [self animateSelfToFrame:rect completion:completion];
}

- (void)animateToSize:(CGSize)size completion:(void (^)(BOOL finished))completion {
    
    CGSize aSize = CGSizeMake([self trueWidthFromValue:size.width],
                              [self trueHeightFromValue:size.height]);
    
    CGPoint scale = CGPointMake(aSize.width/self.bounds.size.width, aSize.height/self.bounds.size.height);
    
    CGRect rect = CGRectMake(self.center.x - (self.bounds.size.width * scale.x) * 0.5f,
                             self.center.y - (self.bounds.size.height * scale.y) * 0.5f,
                             self.bounds.size.width * scale.x,
                             self.bounds.size.height * scale.y);
    
    [self animateSelfToFrame:rect completion:completion];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've begun our editing session.
    if (self.delegate && [self.delegate respondsToSelector:@selector(scalableViewDidBeginEditing:)]) {
        [self.delegate scalableViewDidBeginEditing:self];
    }
    
    self.borderView.resizing = YES;
    UITouch *touch = [touches anyObject];
    self.anchorPoint = [self anchorPointForTouchLocation:[touch locationInView:self]];
    
    // When resizing, all calculations are done in the superview's coordinate space.
    // When translating, all calculations are done in the view's coordinate space.
    self.touchStart = [touch locationInView:[self.anchorPoint isHold] ? self.superview : self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.borderView.resizing = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(scalableViewDidBeginEditing:)]) {
        [self.delegate scalableViewDidBeginEditing:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.borderView.resizing = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(scalableViewDidBeginEditing:)]) {
        [self.delegate scalableViewDidBeginEditing:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.anchorPoint isHold]) {
        [self resizeUsingTouchLocation:[[touches anyObject] locationInView:self.superview]];
    } else {
        [self translateUsingTouchLocation:[[touches anyObject] locationInView:self]];
    }
}

#pragma mark - Private Methods

- (CRVAnchorPoint *)anchorPointForTouchLocation:(CGPoint)touchPoint {
    
    __block CRVAnchorPoint *closestAnchorPoint;
    [self.anchorPoints enumerateObjectsUsingBlock:^(CRVAnchorPoint *anchorPoint, NSUInteger idx, BOOL *stop) {
        [anchorPoint setReferencePointWithSize:self.bounds.size];
        if (anchorPoint.location == CRVAnchorPointLocationCenter) closestAnchorPoint = anchorPoint;
    }];
    
    __block CGFloat minDistance = MAXFLOAT;
    [self.anchorPoints enumerateObjectsUsingBlock:^(CRVAnchorPoint *anchorPoint, NSUInteger idx, BOOL *stop) {
        CGFloat distance = [anchorPoint distanceFromReferencePointToPoint:touchPoint];
        if (distance < minDistance) {
            closestAnchorPoint = anchorPoint;
            minDistance = distance;
        }
    }];
    return closestAnchorPoint;
}

- (void)resizeUsingTouchLocation:(CGPoint)touchPoint {
    // Update the touch point if we're outside the superview.
    CGFloat border = self.borderView.borderInset - 5;;
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
    
    // Calculate the deltas using the current anchor point.
    CGFloat deltaW = self.anchorPoint.adjustsW * (self.touchStart.x - touchPoint.x);
    CGFloat deltaH = self.anchorPoint.adjustsH * (CGFloat)(touchPoint.y - self.touchStart.y);
    CGFloat deltaX = self.anchorPoint.adjustsX * (CGFloat)(-1.0 * deltaW);
    CGFloat deltaY = self.anchorPoint.adjustsY * (CGFloat)(-1.0 * deltaH);
    
    // Calculate the new frame.
    CGFloat newX = self.frame.origin.x + deltaX;
    CGFloat newY = self.frame.origin.y + deltaY;
    CGFloat newWidth = self.frame.size.width + deltaW;
    CGFloat newHeight = self.frame.size.height + deltaH;
    
    CGFloat ratio = CGRectGetWidth(self.bounds)/CGRectGetHeight(self.bounds);

    if (self.isRatioEnabled) {
        
        if (self.anchorPoint.ratioX1 != 0.f || self.anchorPoint.ratioX2 != 0.f) {
            newX += (deltaW * self.anchorPoint.ratioX1) + (deltaH * ratio * self.anchorPoint.ratioX2) - deltaX;
        }
        if (self.anchorPoint.ratioY1 != 0.f || self.anchorPoint.ratioY2 != 0.f) {
            newY += (deltaW/ratio * self.anchorPoint.ratioY1) + (deltaH * self.anchorPoint.ratioY2) - deltaY;
        }
        if (self.anchorPoint.ratioW != 0.f) {
            newWidth += (deltaH * ratio * self.anchorPoint.ratioW) - deltaW;
        }
        if (self.anchorPoint.ratioH != 0.f) {
            newHeight += (deltaW/ratio * self.anchorPoint.ratioH) - deltaH;
        }
    
        // If the new frame is too small or too large, cancel the changes.
        if (newHeight < self.minSize.height || newHeight > self.maxSize.height ||
            newWidth < self.minSize.width || newWidth > self.maxSize.width) {
            
            newHeight = self.frame.size.height;
            newY = self.frame.origin.y;
            newWidth = self.frame.size.width;
            newX = self.frame.origin.x;
        }
        
        // Ensure the resize won't cause the view to move offscreen.
        if (newX < self.superview.bounds.origin.x ||
            newY < self.superview.bounds.origin.y ||
            newX + newWidth > self.superview.bounds.origin.x + self.superview.bounds.size.width ||
            newY + newHeight > self.superview.bounds.origin.y + self.superview.bounds.size.height) {
            
            newHeight = self.frame.size.height;
            newY = self.frame.origin.y;
            newWidth = self.frame.size.width;
            newX = self.frame.origin.x;
        }
        
    } else {
        
        // If the new frame is too small or too large, cancel the changes.
        if (newWidth < self.minSize.width || newWidth > self.maxSize.width) {
            newWidth = self.frame.size.width;
            newX = self.frame.origin.x;
        }
        if (newHeight < self.minSize.height || newHeight > self.maxSize.height) {
            newHeight = self.frame.size.height;
            newY = self.frame.origin.y;
        }
        
        // Ensure the resize won't cause the view to move offscreen.
        if (newX < self.superview.bounds.origin.x) {
            // Calculate how much to grow the width by such that the new X coordintae will align with the superview.
            deltaW = self.frame.origin.x - self.superview.bounds.origin.x;
            newWidth = self.frame.size.width + deltaW;
            newX = self.superview.bounds.origin.x;
        }
        if (newX + newWidth > self.superview.bounds.origin.x + self.superview.bounds.size.width) {
            newWidth = self.superview.bounds.size.width - newX;
        }
        if (newY < self.superview.bounds.origin.y) {
            // Calculate how much to grow the height by such that the new Y coordintae will align with the superview.
            deltaH = self.frame.origin.y - self.superview.bounds.origin.y;
            newHeight = self.frame.size.height + deltaH;
            newY = self.superview.bounds.origin.y;
        }
        if (newY + newHeight > self.superview.bounds.origin.y + self.superview.bounds.size.height) {
            newHeight = self.superview.bounds.size.height - newY;
        }
    }
    
    self.frame = CGRectMake(newX, newY, newWidth, newHeight);
    self.touchStart = touchPoint;
}

- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - self.touchStart.x, self.center.y + touchPoint.y - self.touchStart.y);
    
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
    self.center = newCenter;
}

- (NSArray *)anchorPointsMakeArray {
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < CRVAnchorPointLocationPointsCount; i ++) {
        [array addObject:[[CRVAnchorPoint alloc] initWithLocation:i]];
    }
    return [array copy];
}

- (CGFloat)trueWidthFromValue:(CGFloat)value {
    if (value > self.maxSize.width || value < self.minSize.width) {
        NSLog(@"Given width exceeds min/max width.\nChanged given width to proper one.");
        return MAX(MIN(value, self.maxSize.width), self.minSize.width);
    }
    return value;
}

- (CGFloat)trueHeightFromValue:(CGFloat)value {
    if (value > self.maxSize.height || value < self.minSize.height) {
        NSLog(@"Given height exceeds min/max height.\nChanged given height to proper one.");
        return MAX(MIN(value, self.maxSize.height), self.minSize.height);
    }
    return value;
}

- (void)animateSelfToFrame:(CGRect)frame completion:(void (^)(BOOL finished))completion {
    frame = [self frameByCheckingBoundaries:frame];
    
    [UIView animateWithDuration:self.animationDuration delay:0.f usingSpringWithDamping:self.springDamping initialSpringVelocity:self.springVelocity options:self.animationCurve animations:^{
        [self setFrame:frame];
    } completion:completion];
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

#pragma mark Accessors

- (void)setMinSize:(CGSize)minSize {
    NSAssert(minSize.width > 0, @"Min width cannot be smaller than 0!");
    NSAssert(minSize.height > 0, @"Min height cannot be smaller than 0!");
    _minSize = minSize;
}

@end
