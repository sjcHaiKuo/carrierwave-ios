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

@property (strong, nonatomic, readonly) CRVScalableView *cropView;
@property (strong, nonatomic, readonly) UIImageView *imageView;

@property (assign, nonatomic) BOOL allowToUseGestures;
@property (assign, nonatomic) CGPoint movePoint;

@end
