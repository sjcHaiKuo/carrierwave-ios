//
//  CRVWhitelistManagerDataSource.h
//  Carrierwave
//
//  Created by Grzegorz Lesiak on 30/01/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CRVWhitelistManager;
@class CRVSessionManager;

@protocol CRVWhitelistManagerDataSource <NSObject>

- (CRVSessionManager *)sessionManagerForWhitelistManager:(CRVWhitelistManager *)whitelistManager;
- (NSString *)serverURLForWhitelistManager:(CRVWhitelistManager *)whitelistManager;

@end
