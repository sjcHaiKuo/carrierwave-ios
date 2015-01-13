//
//  CRVHTTPSessionManager.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 05.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface CRVSessionManager : AFHTTPSessionManager

/**
 *  The number of retries used in case of connection issues. Value is set during CRVNetworkManager object initialization.
 */
@property (assign, nonatomic) NSUInteger numberOfRetries;

/**
 *  The time (in seconds) to reconnect after failure. Value is set during CRVNetworkManager object initialization.
 */
@property (assign, nonatomic) NSTimeInterval reconnectionTime;

/**
 *  Whether should check temporary directory before downloading. Value is set during CRVNetworkManager object initialization.
 */
@property (assign, nonatomic) BOOL checkCache;

/**
 *  Tells manager to start uploading file specified by data, name, mimeType on given URL.
 *
 *  @param data       The data object which represents uploaded file.
 *  @param name       The name of uploaded file.
 *  @param mimeType   The mime type of uploaded file.
 *  @param URLString  The relative path of the request.
 *  @param progress   The progress block executed when when manager will receive data from server.
 *  @param completion The completion block executed when the request finishes with error or success. If failed returns an error. Otherwise nil.
 */
- (void)uploadAssetRepresentedByData:(NSData *)data withName:(NSString *)name mimeType:(NSString *)mimeType URLString:(NSString *)URLString progress:(void (^)(double aProgress))progress completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Tells manager to start downloading file from specified URL.
 *
 *  @param URLString  The relative path of the request.
 *  @param progress   The progress block executed when when manager will receive data from server.
 *  @param completion The completion block executed when the request finishes with error or data. If succeed returns data. Otherwise returns an error.
 */
- (void)downloadAssetFromURL:(NSString *)URLString progress:(void (^)(double aProgress))progress completion:(void (^)(NSData *data, NSError *error))completion;

@end
