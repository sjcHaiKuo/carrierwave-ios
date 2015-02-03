//
//  NSError+Carrierwave.h
//  Carrierwave
//
//  Created by Grzegorz Lesiak on 30/01/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Carrierwave)

+ (instancetype)crv_errorForEmptyDataSource;

+ (instancetype)crv_errorForEmptyFile;

@end
