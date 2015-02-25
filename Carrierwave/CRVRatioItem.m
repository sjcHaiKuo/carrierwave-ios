//
//  CRVCropRatio.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 25.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVRatioItem.h"

@implementation CRVRatioItem

- (instancetype)initWithTitle:(NSString *)title ratio:(CGFloat)ratio {
    self = [super init];
    if (self) {
        _title = title;
        _ratio = ratio;
    }
    return self;
}

@end
