//
//  CRVSessionDownloadTaskWrapper.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 13.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionDownloadTaskWrapper.h"

@implementation CRVSessionDownloadTaskWrapper

- (instancetype)initWithTask:(NSURLSessionTask *)task identifier:(NSString *)identifier progress:(CRVProgressBlock)progress completion:(CRVDownloadCompletionDataBlock)completion {
    self = [self initWithTask:task identifier:identifier progress:progress];
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
