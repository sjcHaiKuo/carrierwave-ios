//
//  CRVUploadManager.h
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;
#import "CRVNetworkTypedefs.h"
#import "CRVUploadInfo.h"

@protocol CRVAssetType;
@class CRVImageAsset;

extern NSUInteger const CRVDefaultNumberOfRetries;
extern NSTimeInterval const CRVDefaultReconnectionTime;
extern NSString * const CRVDefaultPath;

@interface CRVNetworkManager : NSObject

/**
 *  Returns a shared instance of network manager
 */
+ (instancetype)sharedManager;

/**
 *  Uploads given asset asynchronously to serverURL concatenated with path param.
 *
 *  @param asset      The asset object to upload.
 *  @param progress   The progress block used to monitor upload progress. Takes values from 0 to 1.
 *  @param completion The completion block performed on server response. If success returns info about upload. Otherwise error.
 *
 *  @return Identifier of uploading proccess. Unique accross an app. Store it to play with proccess later.
 */
- (NSString *)uploadAsset:(id<CRVAssetType>)asset progress:(CRVProgressBlock)progress completion:(CRVUploadCompletionBlock)completion;

/**
 *  Uploads given asset asynchronously to specified URL.
 *
 *  @param asset      The asset object to upload.
 *  @param progress   The progress block used to monitor upload progress. Takes values from 0 to 1.
 *  @param url        The server URL of the server backend used during upload.
 *  @param completion The completion block performed on server response. If success returns info about upload. Otherwise error.
 *
 *  @return Identifier of uploading proccess. Unique accross an app. Store it to play with proccess later.
 */
- (NSString *)uploadAsset:(id<CRVAssetType>)asset toURL:(NSURL *)url progress:(CRVProgressBlock)progress completion:(CRVUploadCompletionBlock)completion;

/**
 *  Downloads asset asynchronously from serverURL concatenated with given path. Returns CRVImageAsset object or error, if any.
 *
 *  @param path       The path which will be concatenated with serverURL.
 *  @param progress   The progress block used to monitor download progress. Takes values from 0 to 1.
 *  @param completion The completion block performed on server response.
 *
 *  @return Identifier of dowloading proccess. Unique accross an app. Store it to play with proccess later.
 */
- (NSString *)downloadAssetFromPath:(NSString *)path progress:(CRVProgressBlock)progress completion:(CRVDownloadCompletionBlock)completion;

/**
 *  Downloads asset asynchronously from specified URL and returns CRVImageAsset object or error, if any.
 *
 *  @param url        The server URL of the server backend used during download.
 *  @param progress   The progress block used to monitor download progress. Takes values from 0 to 1.
 *  @param completion The completion block performed on server response.
 *
 *  @return Identifier of dowloading proccess. Unique accross an app. Store it to play with proccess later.
 */
- (NSString *)downloadAssetFromURL:(NSURL *)url progress:(CRVProgressBlock)progress completion:(CRVDownloadCompletionBlock)completion;

/**
 *  Asynchronously deletes asset with given identifier for default path (param path).
 *
 *  @param identifier The identifier of an asset to delete. It's same identifier as CRVUploadInfo object identifier returned from upload methods.
 *  @param completion The completion block executed on server response. If failed completion block will return error, otherwise nil;
 */
- (void)deleteAssetWithIdentifier:(NSString *)identifier completion:(CRVCompletionBlock)completion;

/**
 *  Asynchronously deletes asset with given identifier from specified url.
 *
 *  @param identifier The identifier of an asset to delete. It's same identifier as CRVUploadInfo object identifier returned from upload methods.
 *  @param url        The url used in request.
 *  @param completion The completion block executed on server response. If failed completion block will return error, otherwise nil;
 */
- (void)deleteAssetWithIdentifier:(NSString *)identifier fromURL:(NSURL *)url completion:(CRVCompletionBlock)completion;


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

/**
 *  The root URL of the server backend.
 */
@property (copy, nonatomic) NSURL *serverURL;

/**
 *  The path append to server URL. Used in all requests (default: CRVDefaultPath);
 */
@property (strong, nonatomic) NSString *path;

/**
 *  Whether the network activity indicator should be visible (default: NO).
 */
@property (assign, nonatomic) BOOL showsNetworkActivityIndicator;

/**
 *  The number of retries used in case of connection issues (default: CRVDefaultNumberOfRetries).
 */
@property (assign, nonatomic) NSUInteger numberOfRetries;

/**
 *  The time (in seconds) to reconnect after failure (default: CRVDefaultReconnectionTime).
 */
@property (assign, nonatomic) NSTimeInterval reconnectionTime;

/**
 *  Whether should check temporary directory before downloading (default: YES).
 */
@property (assign, nonatomic) BOOL checkCache;

@end
