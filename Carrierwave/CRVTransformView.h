//
//  CRVTransformView.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 23.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import UIKit;

#import "CRVScalableView.h"

@interface CRVTransformView : UIView

/**
 *  A crop declaring bounds for croping image.
 */
@property (strong, nonatomic, readonly) CRVScalableView *cropView;

/**
 *  Holds image which will be transformed and cropped
 */
@property (strong, nonatomic, readonly) UIImageView *imageView;

/**
 *  Indicates whether tapped view is crop view or not.
 */
@property (assign, nonatomic) BOOL allowToUseGestures;

@end
