//
//  CRVHTTPSessionManager.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 05.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionManager.h"
#import "CRVSessionTaskManager.h"
#import "CRVNetworkManager.h"

NSString * const CRVServerUploadMethodArgumentName = @"uploadedfile";

CRVWorkInProgress("Check chunked transfer encoding")

static inline NSString * intToString(NSUInteger x) {
    return [NSString stringWithFormat:@"%lu", (unsigned long)x];
}

@interface CRVSessionManager ()

@property (strong, nonatomic) CRVSessionTaskManager *taskManager;

@end

@implementation CRVSessionManager

#pragma mark - Object lifecycle

- (instancetype)init {
    return [self initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super initWithSessionConfiguration:configuration];
    if (self) {
        _taskManager = [[CRVSessionTaskManager alloc] init];
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

- (void)dealloc {
    [self.taskManager cancelAllTasks];
}

#pragma mark - Public Methods

- (NSString *)downloadAssetFromURL:(NSString *)URLString progress:(void (^)(double))progress completion:(void (^)(NSData *, NSError *))completion {
    
    NSData *data = nil;
    if ([CRVNetworkManager sharedManager].checkCache && [self fileDataFromURLString:URLString data:&data]) {
        completion(data, nil);
        return nil;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    
    __weak typeof(self)weakSelf = self;
    __block NSURLSessionDownloadTask *task = [self downloadTaskForRequest:request withCompletionHandler:^(NSURL *filePath, NSError *error) {
        [weakSelf downloadTaskDidPerformCompletionHandler:task filePath:filePath error:error];
    }];
    
    NSUInteger wrapperIdentifier = [self.taskManager addDownloadTask:task progress:progress completion:completion];
    
    [self setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        [weakSelf.taskManager invokeProgressForTask:downloadTask];
    }];
    
    [task resume];
    return intToString(wrapperIdentifier);
}

- (NSString *)uploadAssetRepresentedByDataStream:(NSInputStream *)dataStream withLength:(NSNumber *)length name:(NSString *)name mimeType:(NSString *)mimeType URLString:(NSString *)URLString progress:(void (^)(double))progress completion:(void (^)(BOOL, NSError *))completion {
    
    __weak typeof(self)weakSelf = self;
    NSURLSessionTask *task = [self uploadTaskForDataStream:dataStream length:length name:name mimeType:mimeType URLString:URLString withCompletionHandler:^(NSURLSessionTask *task, NSError *error, id response) {
        [weakSelf uploadTaskDidPerformCompletionHandler:task response:response error:error];
    }];
    NSUInteger wrapperIdentifier = [self.taskManager addUploadTask:task dataStream:dataStream length:length name:name mimeType:mimeType progress:progress completion:completion];

    [self setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        [weakSelf.taskManager invokeProgressForTask:task];
    }];
    
    [task resume];
    return intToString(wrapperIdentifier);
}

- (void)cancelProccessWithIdentifier:(NSString *)identifier {
    [self.taskManager cancelTaskForTaskWrapperIdentifier:identifier.integerValue];
}

- (void)pauseProccessWithIdentifier:(NSString *)identifier {
    [self.taskManager pauseTaskForTaskWrapperIdentifier:identifier.integerValue];
}

- (void)resumeProccessWithIdentifier:(NSString *)identifier {
    [self.taskManager resumeTaskForTaskWrapperIdentifier:identifier.integerValue];
}

#pragma mark - Private Methods

#pragma mark Task initializing:

- (NSURLSessionTask *)uploadTaskForDataStream:(NSInputStream *)dataStream length:(NSNumber *)length name:(NSString *)name mimeType:(NSString *)mimeType URLString:(NSString *)URLString withCompletionHandler:(void (^)(NSURLSessionTask *task, NSError *error, id response))completion {
    return [self POST:URLString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithInputStream:dataStream name:CRVServerUploadMethodArgumentName fileName:name length:length.longLongValue mimeType:mimeType];
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        completion(task, nil, responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(task, error, nil);
    }];
}

- (NSURLSessionDownloadTask *)downloadTaskForRequest:(NSURLRequest *)request withCompletionHandler:(void (^)(NSURL *filePath, NSError *error))completion {
    return [self downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [self targetDirectoryByAppendingFileName:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        completion(filePath, error);
    }];
}

#pragma mark Tasks completion handlers:

- (void)uploadTaskDidPerformCompletionHandler:(NSURLSessionTask *)task response:(id)response error:(NSError *)error {
    CRVSessionUploadTaskWrapper *wrapper = [self.taskManager uploadTaskWrapperForTask:task];
    
    if (!wrapper) { //task has been canceled
        return;
    } else if (!error) {
        [self.taskManager invokeCompletionForUploadTaskWrapper:wrapper error:error];
    } else if ([self shouldPerformCompletionBlockForTaskWrapper:wrapper]) {
        [self.taskManager invokeCompletionForUploadTaskWrapper:wrapper error:error];
    } else {
        [self performDelayedRetriableTaskForTaskWrapper:wrapper];
    }
}

- (void)downloadTaskDidPerformCompletionHandler:(NSURLSessionDownloadTask *)task filePath:(NSURL *)filePath error:(NSError *)error {
    CRVSessionDownloadTaskWrapper *wrapper = [self.taskManager downloadTaskWrapperForTask:task];

    if (!wrapper) { //task has been canceled
        return;
    } else if (!error) {
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:[filePath path]];
        [self.taskManager invokeCompletionForDownloadTaskWrapper:wrapper data:data error:nil];
    } else if ([self shouldPerformCompletionBlockForTaskWrapper:wrapper]) {
        [self.taskManager invokeCompletionForDownloadTaskWrapper:wrapper data:nil error:error];
    } else {
        [self performDelayedRetriableTaskForTaskWrapper:wrapper];
    }
}

#pragma mark Tasks retry logic:

//does number of retries has been exceeded?
- (BOOL)shouldPerformCompletionBlockForTaskWrapper:(CRVSessionTaskWrapper *)wrapper {
    if (wrapper.retriesCount >= [CRVNetworkManager sharedManager].numberOfRetries) {
        NSString *action = [self.taskManager isDownloadTaskWrapper:wrapper] ? @"download" : @"upload";
        NSLog(@"Number of retries limit has been exceeded for asset \"%@\". %@ failed", action, [wrapper fileNameByGuessingFromURLPath]);
        return YES;
    }
    return NO;
}

//execute download/upload asset method once again after specified time
- (void)performDelayedRetriableTaskForTaskWrapper:(CRVSessionTaskWrapper *)wrapper {
    
    BOOL isDownloadTaskWrapper = [self.taskManager isDownloadTaskWrapper:wrapper];
    NSString *action = isDownloadTaskWrapper? @"download" : @"upload";
    NSInteger retriesLeft = [CRVNetworkManager sharedManager].numberOfRetries - wrapper.retriesCount;
    NSTimeInterval reconnectionTime = [CRVNetworkManager sharedManager].reconnectionTime;
    NSLog(@"Retries %@ asset (%@) in %.1f second(s). Retries left: %ld", action, [wrapper fileNameByGuessingFromURLPath], reconnectionTime, (long)retriesLeft);
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(reconnectionTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isDownloadTaskWrapper) {
            [weakSelf executeRetriableDownloadTaskForWrapper:(CRVSessionDownloadTaskWrapper *)wrapper];
        } else {
            [weakSelf executeRetriableUploadTaskForWrapper:(CRVSessionUploadTaskWrapper *)wrapper];
        }
    });
}

- (void)executeRetriableUploadTaskForWrapper:(CRVSessionUploadTaskWrapper *)wrapper {
    wrapper.retriesCount ++;
    
    __weak typeof(self)weakSelf = self;
    NSURLSessionTask *task = [self uploadTaskForDataStream:wrapper.dataStream
                                                    length:wrapper.length
                                                      name:wrapper.name
                                                  mimeType:wrapper.mimeType
                                                 URLString:wrapper.task.originalRequest.URL.path
                                     withCompletionHandler:^(NSURLSessionTask *task, NSError *error, id response) {
        [weakSelf uploadTaskDidPerformCompletionHandler:task response:response error:error];
    }];
    
    wrapper.task = task;
    [task resume];
}

- (void)executeRetriableDownloadTaskForWrapper:(CRVSessionDownloadTaskWrapper *)wrapper {
    wrapper.retriesCount ++;
    
    __weak typeof(self)weakSelf = self;
    __block NSURLSessionDownloadTask *task = nil;
    
    if ([wrapper canResumeTask]) {
        
        task = [self downloadTaskWithResumeData:[wrapper resumeData] progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return [weakSelf targetDirectoryByAppendingFileName:[response suggestedFilename]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            [weakSelf downloadTaskDidPerformCompletionHandler:task filePath:filePath error:error];
        }];
        
    } else {
        task = [self downloadTaskForRequest:wrapper.task.originalRequest withCompletionHandler:^(NSURL *filePath, NSError *error) {
            [weakSelf downloadTaskDidPerformCompletionHandler:task filePath:filePath error:error];
        }];
    }
    
    if (task) {
        wrapper.task = task;
        [task resume];
    }
}

#pragma mark - Helpers

- (NSURL *)targetDirectoryByAppendingFileName:(NSString *)name {
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:name]];
}

- (BOOL)fileDataFromURLString:(NSString *)URLString data:(NSData **)data{
    CRVWorkInProgress("should file name be encoded?")
    NSURL *filePath = [self targetDirectoryByAppendingFileName:[[URLString componentsSeparatedByString:@"/"] lastObject]];
    *data = [[NSFileManager defaultManager] contentsAtPath:[filePath path]];
    return *data ? YES : NO;
}

- (void)resumeDownloadTasks {
    for (CRVSessionDownloadTaskWrapper *wrapper in self.taskManager.downloadTaskWrappers) {
        [self executeRetriableDownloadTaskForWrapper:wrapper];
    }
}

@end
