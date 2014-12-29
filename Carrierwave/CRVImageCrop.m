//
//  CRVImageCrop.m
//
//  Copyright (c) 2014 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVImageCrop.h"

CRVImageCrop CRVImageCropMake(CGRect rect, CGAffineTransform transform) {
    return (CRVImageCrop){
        .rect = rect,
        .transform = transform,
    };
}
