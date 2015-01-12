//
//  CRVTaskManager.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 10.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;
#import "CRVSessionTaskWrapper.h"

@interface CRVSessionTaskManager : NSObject

- (void)invokeProgressBlockForTask:(NSURLSessionTask *)task;

- (void)addDownloadTask:(NSURLSessionDownloadTask *)task withProgressBlock:(CRVProgressBlock)progressBlock completionBlock:(CRVDownloadCompletionBlock)completionBlock;

- (void)addUploadTask:(NSURLSessionUploadTask *)task withProgressBlock:(CRVProgressBlock)progressBlock completionBlock:(CRVUploadCompletionBlock)completionBlock;

- (void)removeDowloadTask:(NSURLSessionDownloadTask *)task;

- (void)removeUploadTask:(NSURLSessionUploadTask *)task;

- (NSArray *)taskWrappers;

- (CRVSessionTaskWrapper *)wrapperForTask:(NSURLSessionTask *)task;

@property (strong, nonatomic, readonly) NSMutableArray *downloadTaskWrappers;

@property (strong, nonatomic, readonly) NSMutableArray *uploadTaskWrappers;

@end
