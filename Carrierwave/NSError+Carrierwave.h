//
//  NSError+Carrierwave.h
//  Carrierwave
//
//  Created by Grzegorz Lesiak on 30/01/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const CRVErrorDomainName;

typedef NS_ENUM(NSInteger, CRVError) {
    CRVErrorWhitelistEmptyDataSource = 1001
};

@interface NSError (Carrierwave)

+ (NSError *)crv_errorWithCode:(CRVError)code userInfo:(NSDictionary *)userInfo;

@end
