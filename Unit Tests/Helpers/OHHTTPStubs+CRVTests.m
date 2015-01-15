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

+ (id<OHHTTPStubsDescriptor>)crv_stubDownloadRequestForIdentifier:(NSString *)identifier {
    
    CRVStubbedNumberOfRetries = 0;
    
    return [self crv_stubRequestsWithIdentifier:identifier response:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSData *data = [NSData crv_defaultImageDataRepresentation];
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
}

#pragma mark - Private Methods

+ (id<OHHTTPStubsDescriptor>)crv_stubRequestsWithIdentifier:(NSString *)identifier response:(OHHTTPStubsResponseBlock)response {
    
    return [self stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        
        if (CRVStubbedNumberOfRetries < [CRVNetworkManager sharedManager].numberOfRetries) {
            CRVStubbedNumberOfRetries ++;
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:nil];
            return [OHHTTPStubsResponse responseWithError:error];
        } else {
            CRVStubbedNumberOfRetries = 0;
            return response(request);
        }
    }];
}

@end
