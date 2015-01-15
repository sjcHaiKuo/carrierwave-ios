//
//  NSData+CRVComposition.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 15.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "NSData+CRVComposition.h"
#import "UIImage+CRVComposition.h"

@implementation NSData (CRVComposition)

+ (instancetype)crv_defaultImageRepresentedByData {
    return UIImagePNGRepresentation([UIImage crv_composeImageWithSize:CGSizeMake(20.f, 20.f) color:[UIColor redColor]]);
}

@end
