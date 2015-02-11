//
//  UIAlertView+Carrierwave.m
//  Carrierwave
//
//  Created by Grzegorz Lesiak on 11/02/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "UIAlertView+Carrierwave.h"

@implementation UIAlertView (Carrierwave)

+ (UIAlertView *)crv_showAlertWithError:(NSError *)error {
    return[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
}

@end
