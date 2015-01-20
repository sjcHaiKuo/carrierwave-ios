//
//  CRVUploadResult.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 20.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRVUploadInfo : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@property (strong, nonatomic, readonly) NSString *assetIdentifier;

@property (strong, nonatomic, readonly) NSString *assetPath;

@end
