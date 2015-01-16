//
//  OHHTTPStubs+CRVTests.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 15.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "OHHTTPStubs.h"

typedef NS_ENUM (NSInteger, CRVStubError) {
    CRVStubErrorNoone,
    CRVStubErrorRetriedAtLeastOnce,
    CRVStubErrorRetriesLimitExceeded
};

@interface OHHTTPStubs (CRVTests)

+ (id<OHHTTPStubsDescriptor>)crv_stubDownloadRequestWithError:(CRVStubError)stubbedError;

+ (NSUInteger)retriesMade;

@end
