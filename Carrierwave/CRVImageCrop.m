//
//  CRVImageCrop.m
//
//  Copyright (c) 2014 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVImageCrop.h"

const CRVImageCrop CRVImageCropZero = {{{0, 0}, {0, 0}}, {1, 0, 0, 1, 0, 0}};

CRVImageCrop CRVImageCropMake(CGRect rect, CGAffineTransform transform) {
    return (CRVImageCrop){
        .rect = rect,
        .transform = transform,
    };
}

CRVImageCrop CRVImageCropIdentity(CGSize size) {
    return (CRVImageCrop){
        .rect = {.origin = CGPointZero, .size = size},
        .transform = CGAffineTransformIdentity,
    };
}
