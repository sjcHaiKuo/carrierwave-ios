//
//  CRVHTTPSessionManager.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 05.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "AFHTTPSessionManager.h"


@interface CRVHTTPSessionManager : AFHTTPSessionManager

- (void)uploadAssetRepresentedByData:(NSData *)data withName:(NSString *)name mimeType:(NSString *)mimeType URLString:(NSString *)URLString completion:(void (^)(BOOL success, NSError *error))completion;

- (void)downloadTaskWithRequest:(NSURLRequest *)request completion:(void (^)(NSData *data, NSError *error))completion;

@end
