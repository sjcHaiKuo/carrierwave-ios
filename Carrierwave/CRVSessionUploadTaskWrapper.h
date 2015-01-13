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

- (instancetype)initWithTask:(NSURLSessionUploadTask *)task progress:(CRVSessionTaskProgress)progress completion:(CRVUploadCompletionHandler)completion;

@property (strong, nonatomic) NSURLSessionUploadTask *task;

@property (copy, nonatomic, readonly) CRVUploadCompletionHandler completion;

@end
