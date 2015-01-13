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

- (instancetype)initWithTask:(NSURLSessionDownloadTask *)task progress:(CRVSessionTaskProgress)progress completion:(CRVDownloadCompletionHandler)completion;

- (NSData *)resumeData;

- (BOOL)canResumeTask;

@property (strong, nonatomic) NSURLSessionDownloadTask *task;

@property (copy, nonatomic, readonly) CRVDownloadCompletionHandler completion;

@end
