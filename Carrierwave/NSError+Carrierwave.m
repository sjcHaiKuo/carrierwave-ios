//
//  NSError+Carrierwave.m
//  Carrierwave
//
//  Created by Grzegorz Lesiak on 30/01/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "NSError+Carrierwave.h"

typedef NS_ENUM(NSInteger, CRVError) {
    CRVErrorUnknown = 1000,
    CRVErrorWhitelistEmptyDataSource,
    CRVErrorEmptyFile
};

static NSString *const CRVErrorDomainName = @"com.carrierwave.domain.network.error";

@implementation NSError (Carrierwave)

#pragma mark - Public Methods

+ (instancetype)crv_errorForEmptyDataSource {
    return [self crv_errorWithCode:CRVErrorWhitelistEmptyDataSource];
}

+ (instancetype)crv_errorForEmptyFile {
    return [self crv_errorWithCode:CRVErrorEmptyFile];
}

#pragma mark - Private Methods

+ (instancetype)crv_errorWithCode:(CRVError)code {
    
    NSString *description = nil;
    
    switch (code) {
        case CRVErrorWhitelistEmptyDataSource:
            description = NSLocalizedString(@"Whitelist needs a data source to be set and valid.", nil);
            break;
        case CRVErrorEmptyFile:
            description = NSLocalizedString(@"Downloaded file is empty.", nil);
            break;
            
        default:
            description = NSLocalizedString(@"An unknown error occurred.", nil);
            break;
    }

    return [NSError errorWithDomain:CRVErrorDomainName code:code userInfo:@{ NSLocalizedDescriptionKey: description }];
}



@end
