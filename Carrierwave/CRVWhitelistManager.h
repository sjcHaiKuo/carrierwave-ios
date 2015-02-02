//
//  CRVWhitelistManager.h
//  Carrierwave
//
//  Created by Grzegorz Lesiak on 30/01/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;

@class CRVSessionManager;
@class CRVWhitelistManager;

@protocol CRVWhitelistManagerDataSource <NSObject>

- (CRVSessionManager *)sessionManagerForWhitelistManager:(CRVWhitelistManager *)whitelistManager;
- (NSString *)serverURLForWhitelistManager:(CRVWhitelistManager *)whitelistManager;

@end

@interface CRVWhitelistManager : NSObject

/**
 *  Loads previously saved whitelista and checks for update
 */
- (void)loadWhitelist;

/**
 *  Checks if the whitelist is valid and tries to fetch any update if its not.
 */
- (void)updateWhitelist;

/**
 *  Check whether the given item is in the whitelist.
 *
 *  @param item      The item to be checked
 *
 *  @return Boolean value indicating whether item is present in the whitelist.
 */
- (BOOL)containsItem:(NSObject *)item;

/**
 * A data source for obtainig necessary data for whitelist management. Setting this property will automatically load a whitelist.
 */
@property (weak, nonatomic) id<CRVWhitelistManagerDataSource> dataSource;

/**
 *  The time interval in which asset types whitelist remains valid, (default: one month).
 */
@property (assign, nonatomic) NSTimeInterval whitelistValidityTime;

/**
 *  The URL subpath for fetching whitelist
 */
@property (copy, nonatomic) NSString *whitelistPath;

@end
