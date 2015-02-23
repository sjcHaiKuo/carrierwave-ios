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

- (void)setImage:(UIImage *)image;

- (CRVScalableView *)cropView;

- (UIImage *)cropImage;

@end
