//
//  CRVTaskManager.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 10.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;

#import "CRVSessionDownloadTaskWrapper.h"
#import "CRVSessionUploadTaskWrapper.h"

@interface CRVSessionTaskManager : NSObject

- (void)invokeProgressForDownloadTask:(NSURLSessionTask *)task;

- (void)invokeCompletionForDownloadTaskWrapper:(CRVSessionDownloadTaskWrapper *)wrapper data:(NSData *)data error:(NSError *)error;

- (void)addDownloadTask:(NSURLSessionDownloadTask *)task progress:(CRVSessionTaskProgress)progress completion:(CRVDownloadCompletionHandler)completion;

- (void)addUploadTask:(NSURLSessionUploadTask *)task progress:(CRVSessionTaskProgress)progress completion:(CRVUploadCompletionHandler)completion;

- (void)removeDowloadTaskWrapper:(CRVSessionDownloadTaskWrapper *)taskWrapper;

- (void)removeUploadTaskWrapper:(CRVSessionUploadTaskWrapper *)taskWrapper;

- (CRVSessionDownloadTaskWrapper *)downloadWrapperForTask:(NSURLSessionTask *)task;

- (CRVSessionUploadTaskWrapper *)uploadWrapperForTask:(NSURLSessionTask *)task;

- (void)cancelAllTasks;

/**
 *  Set from concatanated arrays of download and upload task wrappers.
 *
 *  @return The set populated with CRVSessionDownloadTaskWrapper and CRVSessionUploadTaskWrapper objects.
 */
- (NSSet *)taskWrappers;

/**
 *  An array populated with CRVSessionDownloadTaskWrapper objects.
 *  Objects are in array till will be downloaded, canceled or exceeded number of retries.
 */
@property (strong, nonatomic, readonly) NSMutableArray *downloadTaskWrappers;

/**
 *  An array populated with CRVSessionUploadTaskWrapper objects.
 *  Objects are in array till will be uploaded, canceled or exceeded number of retries.
 */
@property (strong, nonatomic, readonly) NSMutableArray *uploadTaskWrappers;

@end
