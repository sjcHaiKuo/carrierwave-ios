//
//  NSError+Carrierwave.m
//  Carrierwave
//
//  Created by Wojciech Trzasko on 19.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "NSError+Carrierwave.h"

NSString * const CRVDemoErrorDomain = @"co.netguru.lib.carrierwave.ios.error";

typedef NS_ENUM(NSInteger, CRVErrorCode) {
    CRVErrorReadInputData = 101,
};

@implementation NSError (Carrierwave)

+ (NSError *)crv_readInputDataError {
    return [[NSError alloc] initWithDomain:CRVDemoErrorDomain
                                      code:CRVErrorReadInputData
                                  userInfo:@{ NSLocalizedDescriptionKey: @"Error while reading block of input data." }];
}

@end
