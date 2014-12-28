//
//  UIImage+CRVComposition.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "UIImage+CRVComposition.h"

@implementation UIImage (CRVComposition)

+ (instancetype)crv_composeImageWithSize:(CGSize)size color:(UIColor *)color {
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, (CGRect){ .origin = CGPointZero, .size = size });
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
