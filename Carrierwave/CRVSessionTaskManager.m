//
//  CRVTaskManager.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 10.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionTaskManager.h"
#import "NSURLSessionTask+Carrierwave.h"

@interface CRVSessionTaskManager ()

@property (strong, nonatomic, readwrite) NSMutableArray *downloadTaskWrappers;
@property (strong, nonatomic, readwrite) NSMutableArray *uploadTaskWrappers;

@end

@implementation CRVSessionTaskManager

#pragma mark - Public Methods

- (instancetype)init {
    self = [super init];
    if (self) {
        _uploadTaskWrappers = [NSMutableArray array];
        _downloadTaskWrappers = [NSMutableArray array];
    }
    return self;
}

- (NSString *)addDownloadTask:(NSURLSessionTask *)task progress:(CRVProgressBlock)progress completion:(CRVDownloadCompletionDataBlock)completion {
    
    CRVSessionDownloadTaskWrapper *wrapper = [[CRVSessionDownloadTaskWrapper alloc] initWithTask:task identifier:[self uuid] progress:progress completion:completion];
    [self.downloadTaskWrappers addObject:wrapper];
    
    return wrapper.identifier;
}

- (NSString *)addUploadTask:(NSURLSessionTask *)task dataStream:(NSInputStream *)dataStream length:(NSNumber *)length name:(NSString *)name mimeType:(NSString *)mimeType progress:(CRVProgressBlock)progress completion:(CRVUploadCompletionResponseBlock)completion {
    
    CRVSessionUploadTaskWrapper *wrapper = [[CRVSessionUploadTaskWrapper alloc] initWithTask:task identifier:[self uuid] progress:progress completion:completion];
    wrapper.mimeType = mimeType;
    wrapper.dataStream = dataStream;
    wrapper.length = length;
    wrapper.name = name;
    [self.uploadTaskWrappers addObject:wrapper];
    
    return wrapper.identifier;
}

- (NSSet *)taskWrappers {
    NSMutableSet *wrappers = [NSMutableSet setWithArray:self.downloadTaskWrappers];
    [wrappers addObjectsFromArray:self.uploadTaskWrappers];
    return [wrappers copy];
}

- (void)invokeProgressForTask:(NSURLSessionTask *)task {
    dispatch_async(dispatch_get_main_queue(), ^{
        CRVSessionTaskWrapper *wrapper = [self wrapperForTask:task];
        
        if ([wrapper isMemberOfClass:[CRVSessionDownloadTaskWrapper class]]) {
            if (wrapper.progress != NULL) wrapper.progress([task crv_dowloadProgress]);
        } else if ([wrapper isMemberOfClass:[CRVSessionUploadTaskWrapper class]]) {
            if (wrapper.progress != NULL) wrapper.progress([task crv_uploadProgress]);
        }
    });
}

- (void)invokeCompletionForDownloadTaskWrapper:(CRVSessionDownloadTaskWrapper *)wrapper data:(NSData *)data error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (wrapper.completion != NULL) wrapper.completion(data, error);
        [self.downloadTaskWrappers removeObject:wrapper];
    });
}

- (void)invokeCompletionForUploadTaskWrapper:(CRVSessionUploadTaskWrapper *)wrapper response:(NSDictionary *)response error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (wrapper.completion != NULL) wrapper.completion(response, error);
        [self.uploadTaskWrappers removeObject:wrapper];
    });
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

- (void)cancelTaskForTaskWrapperIdentifier:(NSString *)identifier {
    CRVSessionTaskWrapper *wrapper = [self wrapperForIdentifier:identifier];
    [wrapper.task cancel];
    [self.downloadTaskWrappers removeObject:wrapper];
    [self.uploadTaskWrappers removeObject:wrapper];
}

- (void)pauseTaskForTaskWrapperIdentifier:(NSString *)identifier {
    [[self wrapperForIdentifier:identifier].task suspend];
}

- (void)resumeTaskForTaskWrapperIdentifier:(NSString *)identifier {
    [[self wrapperForIdentifier:identifier].task resume];
}

#pragma mark - Private Methods

- (CRVSessionTaskWrapper *)wrapperForTask:(NSURLSessionTask *)task {
    NSSet *set = [self.taskWrappers filteredSetUsingPredicate:[self predicateForTask:task]];
    return [set.allObjects firstObject];
}

- (CRVSessionTaskWrapper *)wrapperForIdentifier:(NSString *)identifier {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.identifier == %@", identifier];
    NSSet *set = [self.taskWrappers filteredSetUsingPredicate:predicate];
    return [set.allObjects firstObject];
}

- (NSPredicate *)predicateForTask:(NSURLSessionTask *)task {
    return [NSPredicate predicateWithFormat:@"SELF.task == %@", task];
}

- (NSString *)uuid {
    NSProcessInfo *proccessInfo = [[NSProcessInfo alloc] init];
    return [proccessInfo globallyUniqueString];
}

@end
