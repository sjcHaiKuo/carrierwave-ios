//
//  CRVCropRatio.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 25.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import UIKit;

@interface CRVRatioItem : NSObject

- (instancetype)initWithTitle:(NSString *)title ratio:(CGFloat)ratio NS_DESIGNATED_INITIALIZER;

@property (strong, nonatomic, readonly) NSString *title;
@property (assign, nonatomic, readonly) CGFloat ratio;

@end
