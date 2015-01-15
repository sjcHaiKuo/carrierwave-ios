//
//  OHHTTPStubs+CRVTests.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 15.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "OHHTTPStubs.h"

@interface OHHTTPStubs (CRVTests)

+ (id<OHHTTPStubsDescriptor>)crv_stubDownloadRequestForIdentifier:(NSString *)identifier;

@end
