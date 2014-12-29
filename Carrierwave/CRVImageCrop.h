//
//  CRVImageCrop.h
//  Carrierwave
//
//  Created by Adrian Kashivskyy on 29.12.2014.
//  Copyright (c) 2014 Netguru Sp. z o.o. All rights reserved.
//

@import CoreGraphics;

/**
 * The CRVImageCrop structure represents a crop of an image.
 *
 * @param rect The rectangle of the crop.
 * @param transform The transform of the image.
 */
typedef struct {
    CGRect rect;
    CGAffineTransform transform;
} CRVImageCrop;

/**
 * Creates a crop structure from a rect and a transform.
 *
 * @param rect The rectangle of the crop.
 * @param transform The transform of the image.
 *
 * @return An initialized structure.
 */
extern CRVImageCrop CRVImageCropMake(CGRect rect, CGAffineTransform transform);
