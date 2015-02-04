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

+ (id<OHHTTPStubsDescriptor>)crv_stubDownloadRequestWithError:(CRVStubError)stubbedError manager:(CRVNetworkManager *)manager {
    
    CRVStubbedNumberOfRetries = 0;
    
    return [self crv_stubRequestsWithError:stubbedError manager:manager response:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSData *data = [NSData crv_defaultImageDataRepresentation];
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
}

+ (id<OHHTTPStubsDescriptor>)crv_stubDeletionRequestWithError:(CRVStubError)stubbedError manager:(CRVNetworkManager *)manager {
    
    CRVStubbedNumberOfRetries = 0;
    
    return [self crv_stubRequestsWithError:stubbedError manager:manager response:^OHHTTPStubsResponse *(NSURLRequest *request) {
        CRVWorkInProgress("temporary JSON");
        NSDictionary *json = @{@"success" : @"YES"};
        return [OHHTTPStubsResponse responseWithJSONObject:json statusCode:200 headers:nil];
    }];
}

+ (id<OHHTTPStubsDescriptor>)crv_stubWhitelistRequestWithError:(CRVStubError)stubbedError manager:(CRVNetworkManager *)manager {
    CRVStubbedNumberOfRetries = 0;
    
    return [self crv_stubRequestsWithError:stubbedError manager:manager response:^OHHTTPStubsResponse *(NSURLRequest *request) {
        CRVWorkInProgress("temporary JSON");
        NSArray *json = @[@"jpg", @"png", @"gif"];
        return [OHHTTPStubsResponse responseWithJSONObject:json statusCode:200 headers:nil];
    }];
}

+ (NSUInteger)retriesMade {
    return CRVStubbedNumberOfRetries;
}

#pragma mark - Private Methods

+ (id<OHHTTPStubsDescriptor>)crv_stubRequestsWithError:(CRVStubError)stubbedError manager:(CRVNetworkManager *)manager response:(OHHTTPStubsResponseBlock)response {
    
    return [self stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        
        NSError *error = nil;
        switch (stubbedError) {
            default:
            case CRVStubErrorNone:
                break;
            case CRVStubErrorRetriesLimitReached: {
                CRVStubbedNumberOfRetries ++;
                if (CRVStubbedNumberOfRetries < manager.numberOfRetries) {
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
