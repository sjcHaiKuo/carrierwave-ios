//
//  CRVTransformViewController.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 23.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import UIKit;

@class CRVScalableView;

@interface CRVTransformViewController : UIViewController

/**
 *  Sets image used in transformation.
 *
 *  @param image Image to transform.
 */
- (void)setImage:(UIImage *)image;

/**
 *  A crop view which declares bounds for croping image.
 *
 *  @return Instance of CRVScalableView.
 */
- (CRVScalableView *)cropView;

/**
 *  Crops an image within crop view.
 *
 *  @return Cropped image.
 */
- (UIImage *)cropImage;

@end
