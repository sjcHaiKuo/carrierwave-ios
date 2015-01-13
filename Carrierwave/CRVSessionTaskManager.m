//
//  CRVTaskManager.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 10.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionTaskManager.h"
#import "NSURLSessionTask+Category.h"

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

- (void)addDownloadTask:(NSURLSessionTask *)task progress:(CRVSessionTaskProgress)progress completion:(CRVDownloadCompletionHandler)completion {
    CRVSessionDownloadTaskWrapper *wrapper = [[CRVSessionDownloadTaskWrapper alloc] initWithTask:task progress:progress completion:completion];
    [self.downloadTaskWrappers addObject:wrapper];
}

- (void)addUploadTask:(NSURLSessionTask *)task data:(NSData *)data name:(NSString *)name mimeType:(NSString *)mimeType progress:(CRVSessionTaskProgress)progress completion:(CRVUploadCompletionHandler)completion {
    CRVSessionUploadTaskWrapper *wrapper = [[CRVSessionUploadTaskWrapper alloc] initWithTask:task progress:progress completion:completion];
    wrapper.mimeType = mimeType;
    wrapper.data = data;
    wrapper.name = name;
    [self.uploadTaskWrappers addObject:wrapper];
}

- (NSSet *)taskWrappers {
    NSMutableSet *wrappers = [NSMutableSet setWithArray:self.downloadTaskWrappers];
    [wrappers addObjectsFromArray:self.uploadTaskWrappers];
    return [wrappers copy];
}

- (void)invokeProgressForTask:(NSURLSessionTask *)task {
    CRVSessionTaskWrapper *wrapper = [self wrapperForTask:task];
    
    if ([wrapper isMemberOfClass:[CRVSessionDownloadTaskWrapper class]]) {
        if (wrapper.progress != NULL) wrapper.progress([task crv_dowloadProgress]);
    } else if ([wrapper isMemberOfClass:[CRVSessionUploadTaskWrapper class]]) {
        if (wrapper.progress != NULL) wrapper.progress([task crv_uploadProgress]);
    }
}

- (void)invokeCompletionForDownloadTaskWrapper:(CRVSessionDownloadTaskWrapper *)wrapper data:(NSData *)data error:(NSError *)error {
    if (wrapper.completion != NULL) wrapper.completion(data, error);
    [self.downloadTaskWrappers removeObject:wrapper];
}

- (void)invokeCompletionForUploadTaskWrapper:(CRVSessionUploadTaskWrapper *)wrapper error:(NSError *)error {
    BOOL success = error ? NO : YES;
    if (wrapper.completion != NULL) wrapper.completion(success, error);
    [self.uploadTaskWrappers removeObject:wrapper];
}

- (CRVSessionDownloadTaskWrapper *)downloadTaskWrapperForTask:(NSURLSessionTask *)task {
    return [[self.downloadTaskWrappers filteredArrayUsingPredicate:[self predicateForTask:task]] firstObject];
}

- (CRVSessionUploadTaskWrapper *)uploadTaskWrapperForTask:(NSURLSessionTask *)task {
    return [[self.uploadTaskWrappers filteredArrayUsingPredicate:[self predicateForTask:task]] firstObject];
}

- (void)cancelAllTasks {
    for (CRVSessionDownloadTaskWrapper *wrapper in self.downloadTaskWrappers) {
        [wrapper.task cancel];
    }
    
    for (CRVSessionUploadTaskWrapper *wrapper in self.uploadTaskWrappers) {
        [wrapper.task cancel];
    }
    [self.downloadTaskWrappers removeAllObjects];
    [self.uploadTaskWrappers removeAllObjects];
}

- (BOOL)isDownloadTaskWrapper:(CRVSessionTaskWrapper *)wrapper {
    return [wrapper isKindOfClass:[CRVSessionDownloadTaskWrapper class]];
}

#pragma mark - Private Methods

- (CRVSessionTaskWrapper *)wrapperForTask:(NSURLSessionTask *)task {
    NSSet *set = [self.taskWrappers filteredSetUsingPredicate:[self predicateForTask:task]];
    return [set.allObjects firstObject];
}

- (NSPredicate *)predicateForTask:(NSURLSessionTask *)task {
    return [NSPredicate predicateWithFormat:@"SELF.task == %@", task];
}

@end
