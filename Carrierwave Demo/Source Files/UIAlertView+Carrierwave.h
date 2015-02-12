//
//  UIAlertView+Carrierwave.h
//  Carrierwave
//
//  Created by Grzegorz Lesiak on 11/02/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Carrierwave)

+ (UIAlertView *)crv_alertWithError:(NSError *)error;

@end
