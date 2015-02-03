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
#import "CRVSessionTaskWrapper+Carrierwave.h"

@interface CRVSessionTaskManager : NSObject

/**
 *  Initializes CRVSessionDownloadTaskWrapper object and adds it to downloadTaskWrapper array.
 *
 *  @param task       The download task with which wrapper is initialized.
 *  @param progress   The progress block with which wrapper is initialized.
 *  @param completion The completion block with which wrapper is initialized.
 */
- (NSString *)addDownloadTask:(NSURLSessionTask *)task progress:(CRVProgressBlock)progress completion:(CRVDownloadCompletionDataBlock)completion;

/**
 *  Initializes CRVSessionUploadTaskWrapper object and adds it to uploadTaskWrapper array.
 *
 *  @param dataStrem  The data stream object which represents uploaded file.
 *  @param length     The length of data stream.
 *  @param task       The upload task with which wrapper is initialized.
 *  @param progress   The progress block with which wrapper is initialized.
 *  @param completion The completion block with which wrapper is initialized.
 */
- (NSString *)addUploadTask:(NSURLSessionTask *)task dataStream:(NSInputStream *)dataStream length:(NSNumber *)length name:(NSString *)name mimeType:(NSString *)mimeType progress:(CRVProgressBlock)progress completion:(CRVUploadCompletionResponseBlock)completion;

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
 *  @param wrapper  The wrapper which completion block should be invoked.
 *  @param error    An error used as a paramater in completion block invocation.
 *  @param response An dictionary with response from server;
 */
- (void)invokeCompletionForUploadTaskWrapper:(CRVSessionUploadTaskWrapper *)wrapper response:(NSDictionary *)response error:(NSError *)error;

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
 *  Cancels a task assigned to task wrapper with given identifier. Also removes wrapper from queue.
 *  NOTICE: Task cancelation will not invoke completion block. May be sent to a wrapper wih task that has been suspended.
 *
 *  @param identifier An identifier for task wrapper, assigned by CRVSessionTaskManager and unique accross an app.
 */
- (void)cancelTaskForTaskWrapperIdentifier:(NSString *)identifier;

/**
 *  Pauses a task assigned to task wrapper with given identifier.
 *  The timeout timer associated with the task will be disabled while a task is paused.
 *
 *  @param identifier An identifier for task wrapper, assigned by CRVSessionTaskManager and unique accross an app.
 */
- (void)pauseTaskForTaskWrapperIdentifier:(NSString *)identifier;

/**
 *  Resumes a task assigned to task wrapper with given identifier.
 *
 *  @param identifier An identifier for task wrapper, assigned by CRVSessionTaskManager and unique accross an app.
 */
- (void)resumeTaskForTaskWrapperIdentifier:(NSString *)identifier;

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
