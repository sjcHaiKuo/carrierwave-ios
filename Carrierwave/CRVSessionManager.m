//
//  CRVHTTPSessionManager.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 05.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionManager.h"
#import "CRVSessionTaskManager.h"

NSString * const CRVDomainErrorName = @"com.carrierwave.domain.network.error";

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
        [weakSelf.taskManager invokeProgressForDownloadTask:downloadTask];
    }];
    
    [task resume];
}

- (void)uploadAssetRepresentedByData:(NSData *)data withName:(NSString *)name mimeType:(NSString *)mimeType URLString:(NSString *)URLString progress:(void (^)(double))progress completion:(void (^)(BOOL, NSError *))completion {
    
    CRVTemporary("Temporary deleted - in implementation");
}

#pragma mark - Private Methods

- (void)resumeDownloadTasks {
    for (CRVSessionDownloadTaskWrapper *wrapper in self.taskManager.downloadTaskWrappers) {
        [self executeRetriableDownloadTaskForWrapper:wrapper];
    }
}

- (void)downloadTaskDidPerformCompletionHandler:(NSURLSessionDownloadTask *)task filePath:(NSURL *)filePath error:(NSError *)error {
    CRVSessionDownloadTaskWrapper *wrapper = [self.taskManager downloadWrapperForTask:task];
    
    //success:
    if (!error) {
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:[filePath path]];
        [self.taskManager invokeCompletionForDownloadTaskWrapper:wrapper data:data error:nil];
        return;
    }
    
    NSString *fileName = [self fileNameFromURL:wrapper.task.originalRequest.URL.path];
    //number of retries exceeded:
    if (wrapper.retriesCount >= self.numberOfRetries) {
        NSLog(@"Number of retries limit has been exceeded for asset \"%@\". Download failed", fileName);
        [self.taskManager invokeCompletionForDownloadTaskWrapper:wrapper data:nil error:error];
        return;
    }

    //execute downloadAsset method once again after specified time:
    __weak typeof(self) weakSelf = self;
    NSInteger retriesLeft = self.numberOfRetries - wrapper.retriesCount;
    NSLog(@"Retries download asset (%@) in %.1f second(s). Left retries: %ld", fileName, self.reconnectionTime, (long)retriesLeft);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.reconnectionTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf executeRetriableDownloadTaskForWrapper:wrapper];
    });
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
        
    } else if (wrapper.task.state == NSURLSessionTaskStateCompleted){ //created new one
        
        task = [self downloadTaskForRequest:wrapper.task.originalRequest withCompletionHandler:^(NSURL *filePath, NSError *error) {
            [self downloadTaskDidPerformCompletionHandler:task filePath:filePath error:error];
        }];
    }
    
    if (task) {
        wrapper.task = task;
        [task resume];
    }
}

- (NSURLSessionDownloadTask *)downloadTaskForRequest:(NSURLRequest *)request withCompletionHandler:(void (^)(NSURL *filePath, NSError *error))completion {
    return [self downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [self targetDirectoryByAppendingFileName:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        completion(filePath, error);
    }];
}

- (NSError *)errorForEmptyFile {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Downloaded file is empty."};
    return [NSError errorWithDomain:CRVDomainErrorName code:0 userInfo:userInfo];
}

- (NSURL *)targetDirectoryByAppendingFileName:(NSString *)name {
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:name]];
}

- (BOOL)fileDataFromURLString:(NSString *)URLString data:(NSData **)data{
    CRVWorkInProgress("should file name be encoded?")
    NSURL *filePath = [self targetDirectoryByAppendingFileName:[self fileNameFromURL:URLString]];
    *data = [[NSFileManager defaultManager] contentsAtPath:[filePath path]];
    return *data ? YES : NO;
}

- (NSString *)fileNameFromURL:(NSString *)URLString {
    return [[URLString componentsSeparatedByString:@"/"] lastObject];
}

@end
