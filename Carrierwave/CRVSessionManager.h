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
 *  Tells manager to start uploading file specified by data, name, mimeType on given URL.
 *
 *  @param data       The data object which represents uploaded file.
 *  @param name       The name of uploaded file.
 *  @param mimeType   The mime type of uploaded file.
 *  @param URLString  The relative path of the request.
 *  @param progress   The progress block executed when when manager will receive data from server.
 *  @param completion The completion block executed when the request finishes with error or success. If failed returns an error. Otherwise nil.
 *
 *  @return Identifier of uploading proccess. Unique accross an app. Store it to play with proccess later.
 */
- (NSString *)uploadAssetRepresentedByData:(NSData *)data withName:(NSString *)name mimeType:(NSString *)mimeType URLString:(NSString *)URLString progress:(void (^)(double aProgress))progress completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Tells manager to start downloading file from specified URL.
 *
 *  @param URLString  The relative path of the request.
 *  @param progress   The progress block executed when when manager will receive data from server.
 *  @param completion The completion block executed when the request finishes with error or data. If succeed returns data. Otherwise returns an error.
 *
 *  @return Identifier of dowloading proccess. Unique accross an app. Store it to play with proccess later.
 */
- (NSString *)downloadAssetFromURL:(NSString *)URLString progress:(void (^)(double aProgress))progress completion:(void (^)(NSData *data, NSError *error))completion;

/**
 *  Cancels a proccess with given identifier.
 *
 *  @param identifier Identifier of running proccess. Unique accross an app.
 */
- (void)cancelProccessWithIdentifier:(NSString *)identifier;

/**
 *  Pauses a proccess with given identifier.
 *
 *  @param identifier Identifier of running proccess. Unique accross an app.
 */
- (void)pauseProccessWithIdentifier:(NSString *)identifier;

/**
 *  Resumes a proccess with given identifier.
 *
 *  @param identifier Identifier of running proccess. Unique accross an app.
 */
- (void)resumeProccessWithIdentifier:(NSString *)identifier;

@end
