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
    CRVStubErrorRetriesReachedRetriesLimit,
    CRVStubErrorRetriesLimitExceeded
};

@interface OHHTTPStubs (CRVTests)

/**
 *  Stubs all incoming requests.
 *
 *  @param stubbedError Defines a behaviour of OHHTTPStubsDescriptor.
 *  @param manager      Network manager used for request.
 *
 *  @return A stub description object.
 */
+ (id<OHHTTPStubsDescriptor>)crv_stubDownloadRequestWithError:(CRVStubError)stubbedError manager:(CRVNetworkManager *)manager;

/**
 *  Number of retries made by manager. Incremented every time request will fail. Depends on CRVStubError.
 */
+ (NSUInteger)retriesMade;

@end