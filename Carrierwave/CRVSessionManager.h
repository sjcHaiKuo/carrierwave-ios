//
//  CRVHTTPSessionManager.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 05.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface CRVSessionManager : AFHTTPSessionManager

@property (assign, nonatomic) NSUInteger numberOfRetries;

@property (assign, nonatomic) NSTimeInterval reconnectionTime;

@property (assign, nonatomic) BOOL checkCache;

- (void)uploadAssetRepresentedByData:(NSData *)data withName:(NSString *)name mimeType:(NSString *)mimeType URLString:(NSString *)URLString progress:(void (^)(double aProgress))progress completion:(void (^)(BOOL success, NSError *error))completion;

- (void)downloadAssetFromURL:(NSString *)URLString progress:(void (^)(double aProgress))progress completion:(void (^)(NSData *data, NSError *error))completion;

@end
