//
//  NSData+CRVComposition.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 15.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "NSData+CRVComposition.h"

@implementation NSData (CRVComposition)

+ (instancetype)crv_defaultImageDataRepresentation {
    return UIImagePNGRepresentation([UIImage crv_composeTestImage]);
}

@end
