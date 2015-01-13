//
//  CRVSessionDownloadTaskWrapper.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 13.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionTaskWrapper.h"

typedef void (^CRVDownloadCompletionHandler)(NSData *, NSError *);

@interface CRVSessionDownloadTaskWrapper : CRVSessionTaskWrapper

/**
 *  Designed initializer for CRVSessionDownloadTaskWrapper class.
 *
 *  @param task       The task which belongs to wrapper.
 *  @param progress   The progress block invoked every time when task will receive data.
 *  @param completion The completion block invoked when task downloading will complete with success or error.
 *
 *  @return An initialized receiver.
 */
- (instancetype)initWithTask:(NSURLSessionTask *)task progress:(CRVSessionTaskProgress)progress completion:(CRVDownloadCompletionHandler)completion;

/**
 *  Downloaded and stored data for task.
 *
 *  @return Data which has been downloaded and generated when task download did fail. Returns nil if task completed with success or is new.
 */
- (NSData *)resumeData;

/**
 *  Indicates if task can be resumed or has to start once again.
 *
 *  @return If task is new or completed with success returns YES. Otherwise NO.
 */
- (BOOL)canResumeTask;

/**
 *  The completion block invoked when task downloading will complete with success or break with an error.
 */
@property (copy, nonatomic, readonly) CRVDownloadCompletionHandler completion;

@end
