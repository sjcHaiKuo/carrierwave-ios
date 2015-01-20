//
//  NSDictionary+Carrierwave.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 20.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "NSDictionary+Carrierwave.h"

@implementation NSDictionary (Carrierwave)

- (NSString *)crv_stringValueForKey:(id)key {
    id obj = [self objectForKey:key];
    
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj stringValue];
    } else {
        return [obj description];
    }
}

@end
