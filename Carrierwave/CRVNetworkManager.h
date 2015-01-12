//
//  CRVUploadManager.h
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;

@protocol CRVAssetType;
@class CRVImageAsset;

typedef void (^CRVDownloadCompletionBlock)(CRVImageAsset *asset, NSError *error);
typedef void (^CRVUploadCompletionBlock)(BOOL success, NSError *error);
typedef void (^CRVProgressBlock)(double progress);

@interface CRVNetworkManager : NSObject

/**
 *  Returns a shared instance of network manager
 */
+ (instancetype)sharedManager;

/**
 *  Uploads given asset asynchronously to serverURL concatenated with uploadPath param.
 *
 *  @param asset      The asset object to upload.
 *  @param progress   The progress block used to monitor upload progress. Takes values from 0 to 1.
 *  @param completion The completion block performed on server response. Returns success flag and error, if any.
 */
- (void)uploadAsset:(id<CRVAssetType>)asset progress:(CRVProgressBlock)progress completion:(CRVUploadCompletionBlock)completion;

/**
 *  Uploads given asset asynchronously to specified URL.
 *
 *  @param asset      The asset object to upload.
 *  @param progress   The progress block used to monitor upload progress. Takes values from 0 to 1.
 *  @param url        The server URL of the server backend used during upload.
 *  @param completion The completion block performed on server response. Returns success flag and error, if any.
 */
- (void)uploadAsset:(id<CRVAssetType>)asset toURL:(NSURL *)url progress:(CRVProgressBlock)progress completion:(CRVUploadCompletionBlock)completion;

/**
 *  Downloads asset asynchronously from serverURL concatenated with given path. Returns CRVImageAsset object or error, if any.
 *
 *  @param path       The path which will be concatenated with serverURL.
 *  @param progress   The progress block used to monitor download progress. Takes values from 0 to 1.
 *  @param completion The completion block performed on server response.
 */
- (void)downloadAssetFromPath:(NSString *)path progress:(CRVProgressBlock)progress completion:(CRVDownloadCompletionBlock)completion;

/**
 *  Downloads asset asynchronously from specified URL and returns CRVImageAsset object or error, if any.
 *
 *  @param url        The server URL of the server backend used during download.
 *  @param progress   The progress block used to monitor download progress. Takes values from 0 to 1.
 *  @param completion The completion block performed on server response.
 */
- (void)downloadAssetFromURL:(NSURL *)url progress:(CRVProgressBlock)progress completion:(CRVDownloadCompletionBlock)completion;

/**
 *  The root URL of the server backend.
 */
@property (copy, nonatomic) NSURL *serverURL;

/**
 *  The upload path used in file upload.
 */
@property (strong, nonatomic) NSString *uploadPath;

/**
 *  Whether the network activity indicator should be visible (default: NO).
 */
@property (assign, nonatomic) BOOL showsNetworkActivityIndicator;

/**
 *  The number of retries in case of connection issues (default: 0).
 */
@property (assign, nonatomic) NSUInteger numberOfRetries;

@end
