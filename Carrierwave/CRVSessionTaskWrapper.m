//
//  CRVSessionTask.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 12.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionTaskWrapper.h"

@implementation CRVSessionTaskWrapper

- (instancetype)initWithUploadTask:(NSURLSessionUploadTask *)task progressBlock:(CRVProgressBlock)progressBlock completionBlock:(CRVUploadCompletionBlock)completionBlock {
    self = [self initWithTask:task progressBlock:progressBlock];
    if (self) {
        _type = CRVSessionTaskWrapperTypeUpload;
        _uploadCompletionBlock = completionBlock;
    }
    return self;
}

- (instancetype)initWithDownloadTask:(NSURLSessionDownloadTask *)task progressBlock:(CRVProgressBlock)progressBlock completionBlock:(CRVDownloadCompletionBlock)completionBlock {
    self = [self initWithTask:task progressBlock:progressBlock];
    if (self) {
        _type = CRVSessionTaskWrapperTypeDownload;
        _downloadCompletionBlock = completionBlock;
    }
    return self;
}

- (instancetype)initWithTask:(NSURLSessionTask *)task progressBlock:(CRVProgressBlock)progressBlock {
    self = [super init];
    if (self) {
        _reconnectionCount = 0;
        _task = task;
        _progressBlock = progressBlock;
    }
    return self;
}

- (NSData *)resumeData {
    return self.task.error.userInfo[NSURLSessionDownloadTaskResumeData];
}

#pragma mark - Private Methods

- (BOOL)isDownloadIncomplete {
    return (self.task.countOfBytesExpectedToReceive != self.task.countOfBytesReceived &&
            self.task.countOfBytesExpectedToReceive != 0);
}

@end
