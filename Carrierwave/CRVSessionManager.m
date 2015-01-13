//
//  CRVHTTPSessionManager.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 05.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionManager.h"
#import "CRVSessionTaskManager.h"

NSString * const CRVServerUploadMethodArgumentName = @"uploadedfile";

CRVWorkInProgress("Check chunked transfer encoding")

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

- (void)downloadAssetFromURL:(NSString *)URLString progress:(void (^)(double))progress completion:(void (^)(NSData *, NSError *))completion {
    
    NSData *data = nil;
    if (self.checkCache && [self fileDataFromURLString:URLString data:&data]) {
        completion(data, nil);
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    __block NSURLSessionDownloadTask *task = [self downloadTaskForRequest:request withCompletionHandler:^(NSURL *filePath, NSError *error) {
        [self downloadTaskDidPerformCompletionHandler:task filePath:filePath error:error];
    }];
    
    [self.taskManager addDownloadTask:task progress:progress completion:completion];
    
    __weak typeof(self)weakSelf = self;
    [self setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        [weakSelf.taskManager invokeProgressForTask:downloadTask];
    }];
    
    [task resume];
}

- (void)uploadAssetRepresentedByData:(NSData *)data withName:(NSString *)name mimeType:(NSString *)mimeType URLString:(NSString *)URLString progress:(void (^)(double))progress completion:(void (^)(BOOL, NSError *))completion {
    
    NSURLSessionTask *task = [self uploadTaskForData:data name:name mimeType:mimeType URLString:URLString];
    [self.taskManager addUploadTask:task data:data name:name mimeType:mimeType progress:progress completion:completion];

    __weak typeof(self)weakSelf = self;
    [self setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        [weakSelf.taskManager invokeProgressForTask:task];
    }];
    
    [task resume];
}

#pragma mark - Private Methods

- (void)resumeDownloadTasks {
    for (CRVSessionDownloadTaskWrapper *wrapper in self.taskManager.downloadTaskWrappers) {
        [self executeRetriableDownloadTaskForWrapper:wrapper];
    }
}

- (void)uploadTaskDidPerformCompletionHandler:(NSURLSessionTask *)task response:(id)response error:(NSError *)error {
    CRVSessionUploadTaskWrapper *wrapper = [self.taskManager uploadTaskWrapperForTask:task];
    
    if (!error) {
        [self.taskManager invokeCompletionForUploadTaskWrapper:wrapper error:error];
    } else if ([self shouldPerformCompletionBlockForTaskWrapper:wrapper]) {
        [self.taskManager invokeCompletionForUploadTaskWrapper:wrapper error:error];
    } else {
        [self performDelayedRetriableTaskForTaskWrapper:wrapper];
    }
}

- (void)downloadTaskDidPerformCompletionHandler:(NSURLSessionDownloadTask *)task filePath:(NSURL *)filePath error:(NSError *)error {
    CRVSessionDownloadTaskWrapper *wrapper = [self.taskManager downloadTaskWrapperForTask:task];
    
    if (!error) {
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:[filePath path]];
        [self.taskManager invokeCompletionForDownloadTaskWrapper:wrapper data:data error:nil];
    } else if ([self shouldPerformCompletionBlockForTaskWrapper:wrapper]) {
        [self.taskManager invokeCompletionForDownloadTaskWrapper:wrapper data:nil error:error];
    } else {
        [self performDelayedRetriableTaskForTaskWrapper:wrapper];
    }
}

- (BOOL)shouldPerformCompletionBlockForTaskWrapper:(CRVSessionTaskWrapper *)wrapper {
    //number of retries exceeded:
    if (wrapper.retriesCount >= self.numberOfRetries) {
        NSString *action = [self.taskManager isDownloadTaskWrapper:wrapper] ? @"download" : @"upload";
        NSLog(@"Number of retries limit has been exceeded for asset \"%@\". %@ failed", action, [wrapper fileNameByGuessingFromURLPath]);
        return YES;
    }
    return NO;
}

//execute download/upload asset method once again after specified time
- (void)performDelayedRetriableTaskForTaskWrapper:(CRVSessionTaskWrapper *)wrapper {
    
    BOOL isDownloadTaskWrapper = [self.taskManager isDownloadTaskWrapper:wrapper];
    NSInteger retriesLeft = self.numberOfRetries - wrapper.retriesCount;
    NSString *action = isDownloadTaskWrapper? @"download" : @"upload";
    NSLog(@"Retries %@ asset (%@) in %.1f second(s). Retries left: %ld", action, [wrapper fileNameByGuessingFromURLPath], self.reconnectionTime, (long)retriesLeft);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.reconnectionTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isDownloadTaskWrapper) {
            [self executeRetriableDownloadTaskForWrapper:(CRVSessionDownloadTaskWrapper *)wrapper];
        } else {
            [self executeRetriableUploadTaskForWrapper:(CRVSessionUploadTaskWrapper *)wrapper];
        }
    });
}

- (void)executeRetriableUploadTaskForWrapper:(CRVSessionUploadTaskWrapper *)wrapper {
    wrapper.retriesCount ++;
    
    NSURLSessionTask *task = [self uploadTaskForData:wrapper.data name:wrapper.name mimeType:wrapper.mimeType URLString:wrapper.task.originalRequest.URL.path];
    
    wrapper.task = task;
    [task resume];
}

- (void)executeRetriableDownloadTaskForWrapper:(CRVSessionDownloadTaskWrapper *)wrapper {
    wrapper.retriesCount ++;
    
    __block NSURLSessionDownloadTask *task = nil;
    
    if ([wrapper canResumeTask]) {
        
        task = [self downloadTaskWithResumeData:[wrapper resumeData] progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return [self targetDirectoryByAppendingFileName:[response suggestedFilename]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            [self downloadTaskDidPerformCompletionHandler:task filePath:filePath error:error];
        }];
        
    } else {
        task = [self downloadTaskForRequest:wrapper.task.originalRequest withCompletionHandler:^(NSURL *filePath, NSError *error) {
            [self downloadTaskDidPerformCompletionHandler:task filePath:filePath error:error];
        }];
    }
    
    if (task) {
        wrapper.task = task;
        [task resume];
    }
}

- (NSURLSessionTask *)uploadTaskForData:(NSData *)data name:(NSString *)name mimeType:(NSString *)mimeType URLString:(NSString *)URLString {
    return [self POST:URLString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:CRVServerUploadMethodArgumentName fileName:name mimeType:mimeType];
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [self uploadTaskDidPerformCompletionHandler:task response:responseObject error:nil];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self uploadTaskDidPerformCompletionHandler:task response:nil error:error];
    }];
}

- (NSURLSessionDownloadTask *)downloadTaskForRequest:(NSURLRequest *)request withCompletionHandler:(void (^)(NSURL *filePath, NSError *error))completion {
    return [self downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [self targetDirectoryByAppendingFileName:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        completion(filePath, error);
    }];
}

- (NSURL *)targetDirectoryByAppendingFileName:(NSString *)name {
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:name]];
}

- (BOOL)fileDataFromURLString:(NSString *)URLString data:(NSData **)data{
    CRVWorkInProgress("should file name be encoded?")
    NSURL *filePath = [self targetDirectoryByAppendingFileName:[[URLString componentsSeparatedByString:@"/"] lastObject]];
    *data = [[NSFileManager defaultManager] contentsAtPath:[filePath path]];
    return *data ? YES : NO;
}

@end
