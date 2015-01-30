//
//  CRVWhitelistManager.h
//  Carrierwave
//
//  Created by Grzegorz Lesiak on 30/01/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRVWhitelistManagerDataSource.h"

@interface CRVWhitelistManager : NSObject

/**
 *  Check whether the given item is in the whitelist.
 *
 *  @param item      The item to be checked
 *
 *  @return Boolean value indicating whether item is present in the whitelist.
 */
- (BOOL)containsItem:(NSObject *)item;

@property (weak, nonatomic) id<CRVWhitelistManagerDataSource> dataSource;

/**
 *  The time interval in which asset types whitelist remains valid, (default: one month).
 */
@property (assign, nonatomic) NSTimeInterval whitelistValidityTime;

/**
 *  The time interval in which asset types whitelist remains valid, (default: one month).
 */
@property (copy, nonatomic) NSString *whitelistPath;

@end
