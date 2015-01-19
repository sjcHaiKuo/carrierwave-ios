//
//  NSError+Carrierwave.h
//  Carrierwave
//
//  Created by Wojciech Trzasko on 19.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Carrierwave)

+ (NSError *)crv_readInputDataError;

@end
