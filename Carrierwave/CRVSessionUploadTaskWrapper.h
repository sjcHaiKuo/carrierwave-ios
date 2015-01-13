//
//  CRVSessionUploadTaskWrapper.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 13.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionTaskWrapper.h"

typedef void (^CRVUploadCompletionHandler)(BOOL, NSError *);

@interface CRVSessionUploadTaskWrapper : CRVSessionTaskWrapper

/**
 *  Designed initializer for CRVSessionUploadTaskWrapper class.
 *
 *  @param task       The upload task which belongs to wrapper.
 *  @param progress   The progress block invoked every time when task will send data.
 *  @param completion The completion block invoked when task uploading will complete with success or error.
 *
 *  @return An initialized receiver.
 */
- (instancetype)initWithTask:(NSURLSessionUploadTask *)task progress:(CRVSessionTaskProgress)progress completion:(CRVUploadCompletionHandler)completion;

/**
 *  Upload task around wrapper is build on.
 */
@property (strong, nonatomic) NSURLSessionUploadTask *task;

/**
 *  The completion block invoked when task uploading will complete with success or break with an error.
 */
@property (copy, nonatomic, readonly) CRVUploadCompletionHandler completion;

@end
