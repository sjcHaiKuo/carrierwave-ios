//
//  CRVSessionDownloadTaskWrapper.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 13.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionDownloadTaskWrapper.h"

@implementation CRVSessionDownloadTaskWrapper

- (instancetype)initWithTask:(NSURLSessionTask *)task progress:(CRVSessionTaskProgress)progress completion:(CRVDownloadCompletionHandler)completion {
    self = [self initWithTask:task progress:progress];
    if (self) {
        _completion = completion;
    }
    return self;
}

- (NSData *)resumeData {
    return self.task.error.userInfo[NSURLSessionDownloadTaskResumeData];
}

- (BOOL)canResumeTask {
    return [self resumeData].length > 0;
}

@end
