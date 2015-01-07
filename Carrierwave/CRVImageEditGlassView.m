//
//  CRVImageEditGlassView.m
//  
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "CRVImageEditGlassView.h"

@interface CRVImageEditGlassView ()

@property (strong, nonatomic, readwrite) UIImage *glassImage;
@property (assign, nonatomic, readwrite) UIEdgeInsets glassImageInsets;

@property (strong, nonatomic) UIImageView *glassImageView;
@property (strong, nonatomic) UIView *glassGhostView;
@property (strong, nonatomic) UIView *maskView;

@end

#pragma mark -

@implementation CRVImageEditGlassView

#pragma mark - Object lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) return nil;

    self.glassGhostView = [[UIView alloc] init];
    self.glassGhostView.userInteractionEnabled = NO;
    self.glassGhostView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.glassGhostView];

    self.maskView = [[UIView alloc] init];
    self.maskView.userInteractionEnabled = NO;
    self.maskView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.maskView];

    self.glassImageView = [[UIImageView alloc] init];
    self.glassImageView.userInteractionEnabled = NO;
    self.glassImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.glassImageView];

    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];

    self.maskColor = [UIColor clearColor];
    self.glassRatio = 1;
    self.glassInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    self.glassImage = [[self class] defaultGlassImage];
    self.glassImageInsets = [[self class] defaultGlassImageInsets];

    return self;
}

#pragma mark - View lifecycle

- (void)updateConstraints {

    [self.glassGhostView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(self.glassInsets).priorityHigh();
        make.height.equalTo(self.glassGhostView.mas_width).dividedBy(self.glassRatio);
        make.center.equalTo(self);
    }];

    [self.glassImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.glassGhostView).with.insets(self.glassImageInsets);
    }];

    [self.maskView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [super updateConstraints];
}

- (void)layoutSubviews {

    [super layoutSubviews];

    [self updateMaskViewMaskLayer];

    if([self.delegate respondsToSelector:@selector(imageEditGlassViewDidChangeGlassRect:)]) {
        [self.delegate imageEditGlassViewDidChangeGlassRect:self];
    }
    
}

- (void)updateMaskViewMaskLayer {

    CGRect boundsRect = self.maskView.bounds;
    CGRect holeRect = [self.maskView convertRect:self.glassGhostView.bounds fromView:self.glassGhostView];

    CGMutablePathRef path = CGPathCreateMutable();

    CGPathMoveToPoint(path, NULL, CGRectGetMinX(boundsRect), CGRectGetMinY(boundsRect));
    CGPathAddLineToPoint(path, NULL, CGRectGetMinX(boundsRect), CGRectGetMaxY(boundsRect));
    CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(boundsRect), CGRectGetMaxY(boundsRect));
    CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(boundsRect), CGRectGetMinY(boundsRect));
    CGPathAddLineToPoint(path, NULL, CGRectGetMinX(boundsRect), CGRectGetMinY(boundsRect));

    CGPathMoveToPoint(path, NULL, CGRectGetMinX(holeRect), CGRectGetMinY(holeRect));
    CGPathAddLineToPoint(path, NULL, CGRectGetMinX(holeRect), CGRectGetMaxY(holeRect));
    CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(holeRect), CGRectGetMaxY(holeRect));
    CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(holeRect), CGRectGetMinY(holeRect));
    CGPathAddLineToPoint(path, NULL, CGRectGetMinX(holeRect), CGRectGetMinY(holeRect));

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    [maskLayer setPath:path]; CFRelease(path);
    [maskLayer setFillRule:kCAFillRuleEvenOdd];
    [maskLayer setFillColor:[UIColor blackColor].CGColor];

    self.maskView.layer.mask = maskLayer;

}

#pragma mark - Geometry additions

- (CGRect)convertGlassRectToCoordinateSpace:(id<UICoordinateSpace>)coordinateSpace {
    return [coordinateSpace convertRect:self.glassGhostView.bounds fromCoordinateSpace:self.glassGhostView];
}

#pragma mark - Public property accessors

- (UIColor *)maskColor {
    return self.maskView.backgroundColor;
}

- (void)setMaskColor:(UIColor *)maskColor {
    self.maskView.backgroundColor = maskColor;
}

- (void)setGlassRatio:(CGFloat)glassRatio {
    if (_glassRatio != glassRatio) {
        _glassRatio = glassRatio;
        [self setNeedsUpdateConstraints];
        [self setNeedsLayout];
    }
}

- (void)setGlassInsets:(UIEdgeInsets)glassInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_glassInsets, glassInsets)) {
        _glassInsets = glassInsets;
        [self setNeedsUpdateConstraints];
        [self setNeedsLayout];
    }
}

- (UIImage *)glassImage {
    return self.glassImageView.image;
}

- (void)setGlassImage:(UIImage *)glassImage {
    self.glassImageView.image = glassImage;
}

- (void)setGlassImageInsets:(UIEdgeInsets)glassImageInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_glassImageInsets, glassImageInsets)) {
        _glassImageInsets = glassImageInsets;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setGlassImage:(UIImage *)glassImage withInsets:(UIEdgeInsets)glassImageInsets {
    self.glassImage = glassImage;
    self.glassImageInsets = glassImageInsets;
}

#pragma mark - Private property accessors

+ (UIImage *)defaultGlassImage {

    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = CGSizeMake((40 * scale), (40 * scale));
    UIEdgeInsets insets = UIEdgeInsetsMake(18, 18, 18, 18);

    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, scale, scale);

    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:(CGFloat)0.9 alpha:1].CGColor);
    CGContextSetLineWidth(context, 2);

    CGContextMoveToPoint(context, 1, 16);
    CGContextAddLineToPoint(context, 1, 1);
    CGContextAddLineToPoint(context, 16, 1);

    CGContextMoveToPoint(context, 24, 1);
    CGContextAddLineToPoint(context, 39, 1);
    CGContextAddLineToPoint(context, 39, 16);

    CGContextMoveToPoint(context, 39, 24);
    CGContextAddLineToPoint(context, 39, 39);
    CGContextAddLineToPoint(context, 24, 39);

    CGContextMoveToPoint(context, 16, 39);
    CGContextAddLineToPoint(context, 1, 39);
    CGContextAddLineToPoint(context, 1, 24);

    CGContextStrokePath(context);
    CGContextSetLineWidth(context, 1);

    CGContextAddRect(context, CGRectMake(2.5, 2.5, 35, 35));

    CGContextStrokePath(context);

    CGImageRef cgImage = CGBitmapContextCreateImage(context); UIGraphicsEndImageContext();
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:scale orientation:UIImageOrientationUp]; CFRelease(cgImage);

    return [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    
}

+ (UIEdgeInsets)defaultGlassImageInsets {
    return UIEdgeInsetsMake(-2, -2, -2, -2);
}

@end
