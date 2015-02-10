//
//  NSError+Carrierwave.h
//  Carrierwave
//
//  Created by Grzegorz Lesiak on 30/01/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Carrierwave)

/**
 *  Creates an error with proper domain, code and description when data source is not specified.
 *
 *  @return An instance of receiver.
 */
+ (instancetype)crv_errorForEmptyDataSource;

/**
 *  Creates an error with proper domain, code and description when downloaded file is empty.
 *
 *  @return An instance of receiver.
 */
+ (instancetype)crv_errorForEmptyFile;

/**
 *  as
 */
+ (instancetype)crv_errorForWrongMimeType:(NSString *)mimeType;

@end
