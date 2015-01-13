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

/**
 *  Initializes CRVSessionDownloadTaskWrapper object and adds it to downloadTaskWrapper array.
 *
 *  @param task       The download task with which wrapper is initialized.
 *  @param progress   The progress block with which wrapper is initialized.
 *  @param completion The completion block with which wrapper is initialized.
 */
- (void)addDownloadTask:(NSURLSessionTask *)task progress:(CRVSessionTaskProgress)progress completion:(CRVDownloadCompletionHandler)completion;

/**
 *  Initializes CRVSessionUploadTaskWrapper object and adds it to uploadTaskWrapper array.
 *
 *  @param task       The upload task with which wrapper is initialized.
 *  @param progress   The progress block with which wrapper is initialized.
 *  @param completion The completion block with which wrapper is initialized.
 */
- (void)addUploadTask:(NSURLSessionTask *)task data:(NSData *)data name:(NSString *)name mimeType:(NSString *)mimeType progress:(CRVSessionTaskProgress)progress completion:(CRVUploadCompletionHandler)completion;

/**
 *  Invokes progress block stored in approperiate wrapper for given task.
 *
 *  @param task The task which is used to find appropriate wrapper.
 */
- (void)invokeProgressForTask:(NSURLSessionTask *)task;

/**
 *  Invokes completion block stored in download task wrapper.
 *
 *  @param wrapper The wrapper which completion block should be invoked.
 *  @param data    A data used as a paramater in completion block invocation.
 *  @param error   An error used as a paramater in completion block invocation.
 */
- (void)invokeCompletionForDownloadTaskWrapper:(CRVSessionDownloadTaskWrapper *)wrapper data:(NSData *)data error:(NSError *)error;

/**
 *  Invokes completion block stored in upload task wrapper.
 *
 *  @param wrapper The wrapper which completion block should be invoked.
 *  @param error   An error used as a paramater in completion block invocation.
 */
- (void)invokeCompletionForUploadTaskWrapper:(CRVSessionUploadTaskWrapper *)wrapper error:(NSError *)error;

/**
 *  Finds appropriate wrapper for specified download task. If doesn't exist, returns nil.
 *
 *  @param task The download task around which wrapper has been built around.
 *
 *  @return An instance of CRVSessionDownloadTaskWrapper object build around specified download task.
 */
- (CRVSessionDownloadTaskWrapper *)downloadTaskWrapperForTask:(NSURLSessionTask *)task;

/**
 *  Finds appropriate wrapper for specified upload task. If doesn't exist, returns nil.
 *
 *  @param task The upload task around which wrapper has been built around.
 *
 *  @return An instance of CRVSessionUploadTaskWrapper object build around specified upload task.
 */
- (CRVSessionUploadTaskWrapper *)uploadTaskWrapperForTask:(NSURLSessionTask *)task;

/**
 *  Cancel all tasks and removes all wrappers gathered in download and upload wrapper arrays.
 */
- (void)cancelAllTasks;

/**
 *  Set from concatanated arrays of download and upload task wrappers.
 *
 *  @return The set populated with CRVSessionDownloadTaskWrapper and CRVSessionUploadTaskWrapper objects.
 */
- (NSSet *)taskWrappers;

/**
 *  Checks class type of specified wrapper.
 *
 *  @param wrapper Wrapper which class will be checked.
 *
 *  @return Flag if given wrapper is CRVSessionDownloadTaskWrapper class or not.
 */
- (BOOL)isDownloadTaskWrapper:(CRVSessionTaskWrapper *)wrapper;

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
