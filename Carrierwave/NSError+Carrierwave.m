//
//  NSError+Carrierwave.m
//  Carrierwave
//
//  Created by Grzegorz Lesiak on 30/01/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "NSError+Carrierwave.h"

NSString *const CRVErrorDomainName = @"com.carrierwave.domain.network.error";

@implementation NSError (Carrierwave)

+ (NSError *)crv_errorWithCode:(CRVError)code userInfo:(NSDictionary *)userInfo {
    return [NSError errorWithDomain:CRVErrorDomainName code:code userInfo:userInfo];
}

@end
