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
    CRVErrorEmptyFile,
    CRVErrorWrongMimeType
};

static NSString *const CRVErrorDomainName = @"com.carrierwave.domain.network.error";

@implementation NSError (Carrierwave)

#pragma mark - Public Methods

+ (instancetype)crv_errorForEmptyDataSource {
    return [self crv_errorWithCode:CRVErrorWhitelistEmptyDataSource localizedDescription:NSLocalizedString(@"Whitelist needs a data source to be set and valid.", nil)];
}

+ (instancetype)crv_errorForEmptyFile {
    return [self crv_errorWithCode:CRVErrorEmptyFile localizedDescription:NSLocalizedString(@"Downloaded file is empty.", nil)];
}

+ (instancetype)crv_errorForWrongMimeType:(NSString *)mimeType {
    return [self crv_errorWithCode:CRVErrorWrongMimeType localizedDescription:[NSString stringWithFormat:NSLocalizedString(@"Mime type %@ is not allowed.", nil), mimeType]];
}

#pragma mark - Private Methods

+ (NSError *)crv_errorWithCode:(NSInteger)code localizedDescription:(NSString *)localizedDescription {
    
    if (!localizedDescription) {
        localizedDescription = NSLocalizedString(@"An unknown error occurred.", nil);
    }
    return [NSError errorWithDomain:CRVErrorDomainName
                               code:code
                           userInfo:@{ NSLocalizedDescriptionKey: localizedDescription}];
}



@end
