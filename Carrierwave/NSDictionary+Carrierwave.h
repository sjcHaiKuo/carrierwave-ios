//
//  NSDictionary+Carrierwave.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 20.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Carrierwave)

/**
 *  Return value associated wth key, converted to NSString
 */
- (NSString *)crv_stringValueForKey:(id)key;

@end
