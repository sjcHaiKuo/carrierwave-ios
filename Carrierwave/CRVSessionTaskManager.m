//
//  CRVTaskManager.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 10.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionTaskManager.h"

@interface CRVSessionTaskManager ()

@property (strong, nonatomic, readwrite) NSMutableArray *downloadTaskWrappers;
@property (strong, nonatomic, readwrite) NSMutableArray *uploadTaskWrappers;

@end

@implementation CRVSessionTaskManager

#pragma mark - Public Methods

- (instancetype)init {
    self = [super init];
    if (self) {
        _downloadTaskWrappers = [NSMutableArray array];
        _uploadTaskWrappers = [NSMutableArray array];
    }
    return self;
}

- (void)addDownloadTask:(NSURLSessionDownloadTask *)task withProgressBlock:(CRVProgressBlock)progressBlock completionBlock:(CRVDownloadCompletionBlock)completionBlock {
    CRVSessionTaskWrapper *wrapper = [[CRVSessionTaskWrapper alloc] initWithDownloadTask:task progressBlock:progressBlock completionBlock:completionBlock];
    [self.downloadTaskWrappers addObject:wrapper];
}

- (void)addUploadTask:(NSURLSessionUploadTask *)task withProgressBlock:(CRVProgressBlock)progressBlock completionBlock:(CRVUploadCompletionBlock)completionBlock {
    CRVSessionTaskWrapper *wrapper = [[CRVSessionTaskWrapper alloc] initWithUploadTask:task progressBlock:progressBlock completionBlock:completionBlock];
    [self.uploadTaskWrappers addObject:wrapper];
}

- (NSArray *)taskWrappers {
    NSMutableArray *wrappers = [NSMutableArray arrayWithArray:self.downloadTaskWrappers];
    [wrappers addObjectsFromArray:self.uploadTaskWrappers];
    return [wrappers copy];
}

- (void)removeDowloadTask:(NSURLSessionDownloadTask *)task {
    [self.downloadTaskWrappers removeObject:[self wrapperForTask:task]];
}

- (void)removeUploadTask:(NSURLSessionUploadTask *)task {
    [self.uploadTaskWrappers removeObject:[self wrapperForTask:task]];
}

- (void)invokeProgressBlockForTask:(NSURLSessionTask *)task {
    CRVProgressBlock progressBlock = [self wrapperForTask:task].progressBlock;
    if (progressBlock != NULL) progressBlock(task);
}

- (CRVSessionTaskWrapper *)wrapperForTask:(NSURLSessionTask *)task {
    NSArray *array = [self.taskWrappers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.task == %@", task]];
    return [array firstObject];
}

@end
