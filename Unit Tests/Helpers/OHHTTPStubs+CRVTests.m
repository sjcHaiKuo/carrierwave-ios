//
//  OHHTTPStubs+CRVTests.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 15.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "OHHTTPStubs+CRVTests.h"

static NSUInteger CRVStubbedNumberOfRetries;

@implementation OHHTTPStubs (CRVTests)

#pragma mark - Public Methods

+ (id<OHHTTPStubsDescriptor>)crv_stubDownloadRequestWithError:(CRVStubError)stubbedError {
    
    CRVStubbedNumberOfRetries = 0;
    
    return [self crv_stubRequestsWithError:stubbedError response:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSData *data = [NSData crv_defaultImageDataRepresentation];
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
}

+ (id<OHHTTPStubsDescriptor>)crv_stubUploadRequestWithError:(CRVStubError)stubbedError {
    
    CRVStubbedNumberOfRetries = 0;
    
    return [self crv_stubRequestsWithError:stubbedError response:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSData *data = [NSData crv_defaultImageDataRepresentation];
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
}

+ (NSUInteger)retriesMade {
    return CRVStubbedNumberOfRetries;
}

#pragma mark - Private Methods

+ (id<OHHTTPStubsDescriptor>)crv_stubRequestsWithError:(CRVStubError)stubbedError response:(OHHTTPStubsResponseBlock)response {
    
    return [self stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        
        NSError *error = nil;
        
        switch (stubbedError) {
            default:
            case CRVStubErrorNoone:
                break;
            case CRVStubErrorRetriedAtLeastOnce: {
                CRVStubbedNumberOfRetries ++;
                if (CRVStubbedNumberOfRetries < [CRVNetworkManager sharedManager].numberOfRetries) {
                    error = [NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:nil];
                }
                break;
            }
            case CRVStubErrorRetriesLimitExceeded: {
                CRVStubbedNumberOfRetries ++;
                error = [NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:nil];
                break;
            }
        }
        return error ? [OHHTTPStubsResponse responseWithError:error] : response(request);
    }];
}


@end
