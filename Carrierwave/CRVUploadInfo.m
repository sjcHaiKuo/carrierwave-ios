//
//  CRVUploadResult.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 20.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVUploadInfo.h"
#import "NSDictionary+Carrierwave.h"

@implementation CRVUploadInfo

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            _assetIdentifier = [dictionary[@"attachment"] crv_stringValueForKey:@"id"];
            _assetPath = dictionary[@"attachment"][@"file"];
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, identifier: %@, path: %@>", NSStringFromClass([self class]), self, self.assetIdentifier, self.assetPath];
}

@end
