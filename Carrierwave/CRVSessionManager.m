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

static void executeAfter(NSTimeInterval delayInSeconds, dispatch_block_t block) {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
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
    
    NSParameterAssert(URLString);
    NSData *data = nil;
    if ([self checkCache] && [self fileDataFromURLString:URLString data:&data]) {
        completion(data, nil);
        return nil;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    
    __weak typeof(self) weakSelf = self;
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

- (NSString *)uploadAssetRepresentedByDataStream:(NSInputStream *)dataStream withLength:(NSNumber *)length name:(NSString *)name mimeType:(NSString *)mimeType URLString:(NSString *)URLString progress:(void (^)(double))progress completion:(void (^)(NSDictionary *, NSError *))completion {
    
     NSParameterAssert(dataStream); NSParameterAssert(length);      NSParameterAssert(name);
     NSParameterAssert(mimeType);   NSParameterAssert(URLString);
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionTask *task = [self uploadTaskForDataStream:dataStream length:length name:name mimeType:mimeType URLString:URLString withCompletionHandler:^(NSURLSessionTask *task, NSError *error, id response) {
        [weakSelf uploadTaskDidPerformCompletionHandler:task response:response error:error];
    }];
    NSUInteger wrapperIdentifier = [self.taskManager addUploadTask:task dataStream:dataStream length:length name:name mimeType:mimeType progress:progress completion:completion];

    [self setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        [weakSelf.taskManager invokeProgressForTask:task];
    }];
    
    return intToString(wrapperIdentifier);
}

- (void)deleteAssetFromURL:(NSString *)URLString completion:(void (^)(BOOL, NSError *))completion {
   
    [self executeNumberOfTimes:[self numberOfRetries] retriableBlock:^(CRVCompletionBlock completion) {
        [self DELETE:URLString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if (completion != NULL) completion(YES, nil);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (completion != NULL) completion(NO, error);
        }];
    } completion:completion];
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
        [self.taskManager invokeCompletionForUploadTaskWrapper:wrapper response:response error:error];
    } else if ([self shouldPerformCompletionBlockForTaskWrapper:wrapper]) {
        [self.taskManager invokeCompletionForUploadTaskWrapper:wrapper response:response error:error];
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

- (void)executeNumberOfTimes:(NSInteger)numberOfTimes retriableBlock:(void (^)(CRVCompletionBlock block))retriable completion:(CRVCompletionBlock)completion {
    
    __block NSInteger retriesCounter = numberOfTimes;
    
    retriable(^(BOOL success, NSError *error) {
        BOOL retryPossible = (retriesCounter > 0);
        if (error && retryPossible) {
            retriesCounter--;
            [self logRetryInfoForOperation:@"delete" fileName:nil retriesLeft:retriesCounter];
            __weak typeof(self) weakSelf = self;
            executeAfter([self reconnectionTime], ^{
                [weakSelf executeNumberOfTimes:retriesCounter retriableBlock:retriable completion:completion];
            });
        } else {
            if (!retryPossible) [self logRetriesExceededInfoForOperation:@"Deletion" fileName:nil];
            if (completion != NULL) completion(success, error);
        }
    });
}

//does number of retries has been exceeded?
- (BOOL)shouldPerformCompletionBlockForTaskWrapper:(CRVSessionTaskWrapper *)wrapper {
    if (wrapper.retriesCount >= [self numberOfRetries]) {
        NSString *operation = [self.taskManager isDownloadTaskWrapper:wrapper] ? @"Download" : @"Upload";
        [self logRetriesExceededInfoForOperation:operation fileName:[wrapper fileNameByGuessingFromURLPath]];
        return YES;
    }
    return NO;
}

//execute download/upload asset method once again after specified time
- (void)performDelayedRetriableTaskForTaskWrapper:(CRVSessionTaskWrapper *)wrapper {
    
    BOOL isDownloadTaskWrapper = [self.taskManager isDownloadTaskWrapper:wrapper];
    NSString *operation = isDownloadTaskWrapper? @"download" : @"upload";
    NSInteger retriesLeft = [self numberOfRetries] - wrapper.retriesCount;
    [self logRetryInfoForOperation:operation fileName:[wrapper fileNameByGuessingFromURLPath] retriesLeft:retriesLeft];
    
    __weak typeof(self) weakSelf = self;
    executeAfter([self reconnectionTime], ^{
        if (isDownloadTaskWrapper) {
            [weakSelf executeRetriableDownloadTaskForWrapper:(CRVSessionDownloadTaskWrapper *)wrapper];
        } else {
            [weakSelf executeRetriableUploadTaskForWrapper:(CRVSessionUploadTaskWrapper *)wrapper];
        }
    });
}

- (void)executeRetriableUploadTaskForWrapper:(CRVSessionUploadTaskWrapper *)wrapper {
    wrapper.retriesCount ++;
    
    __weak typeof(self) weakSelf = self;
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
    
    __weak typeof(self) weakSelf = self;
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
    NSURL *filePath = [self targetDirectoryByAppendingFileName:[[URLString componentsSeparatedByString:@"/"] lastObject]];
    *data = [[NSFileManager defaultManager] contentsAtPath:[filePath path]];
    return *data ? YES : NO;
}

- (void)logRetryInfoForOperation:(NSString *)operation fileName:(NSString *)fileName retriesLeft:(NSUInteger)retriesLeft {
    NSString *helper = fileName ? [NSString stringWithFormat:@"(%@) ", fileName] : @"";
    NSLog(@"Retries %@ asset %@in %.1f second(s). Retries left: %ld", operation, helper, [self reconnectionTime], (long)retriesLeft);
}

- (void)logRetriesExceededInfoForOperation:(NSString *)operation fileName:(NSString *)fileName {
    NSString *helper = fileName ? [NSString stringWithFormat:@" for asset \"%@\"", fileName] : @"";
    NSLog(@"Number of retries limit has been exceeded%@. %@ failed", helper, operation);
}

#pragma mark - CRVSessionManagerDelegate Methods

- (void)resumeDownloadTasks {
    for (CRVSessionDownloadTaskWrapper *wrapper in self.taskManager.downloadTaskWrappers) {
        [self executeRetriableDownloadTaskForWrapper:wrapper];
    }
}

- (BOOL)checkCache {
    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldSessionMangerCheckCache:)]) {
        return [self.delegate shouldSessionMangerCheckCache:self];
    }
    return [CRVNetworkManager sharedManager].checkCache;
}

- (NSUInteger)numberOfRetries {
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfRetriesSessionManagerShouldPrepare:)]) {
        return [self.delegate numberOfRetriesSessionManagerShouldPrepare:self];
    }
    return [CRVNetworkManager sharedManager].numberOfRetries;
}

- (NSTimeInterval)reconnectionTime {
    if (self.delegate && [self.delegate respondsToSelector:@selector(reconnectionTimeSessionManagerShouldWait:)]) {
        return [self.delegate reconnectionTimeSessionManagerShouldWait:self];
    }
    return [CRVNetworkManager sharedManager].reconnectionTime;
}

@end
