//
//  CRVHTTPSessionManager.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 05.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionManager.h"
#import "CRVSessionTaskManager.h"
#import "NSURLSessionTask+Category.h"

#import "CRVSessionTaskWrapper.h"

NSString * const CRVDomainName = @"com.carrierwave.domain";
NSString * const CRVDomainErrorName = @"com.carrierwave.domain.network.error";

@interface CRVSessionManager ()

@property (strong, nonatomic) CRVSessionTaskManager *taskManager;

@end

@implementation CRVSessionManager

CRVTemporary("Whole class refactor is strongly required");
CRVTemporary("Logic should be simpler.");

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
        [self startMonitoringNetworkStatus];
    }
    return self;
}

- (void)dealloc {
    [self cancelAllRequests];
}

#pragma mark - Public Methods

- (void)downloadAssetFromURL:(NSString *)URLString progress:(void (^)(double))progress completion:(void (^)(NSData *, NSError *))completion {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    
    __block NSURLSessionDownloadTask *task = [self downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [self targetDirectoryByAppendingFileName:[response suggestedFilename]];
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [self performAssetCompletionHandlerWithTask:task filePath:filePath error:error block:completion];
    }];
    
    [self.taskManager addDownloadTask:task withProgressBlock:^(NSURLSessionTask *task) {
        if (progress != NULL) progress([task crv_dowloadProgress]);
    } completionBlock:completion];
    
    __weak typeof(self)weakSelf = self;
    [self setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        [weakSelf.taskManager invokeProgressBlockForTask:downloadTask];
    }];
    
    [task resume];
}

- (void)uploadAssetRepresentedByData:(NSData *)data withName:(NSString *)name mimeType:(NSString *)mimeType URLString:(NSString *)URLString progress:(void (^)(double))progress completion:(void (^)(BOOL, NSError *))completion {
    
    CRVTemporary("Temporary deleted - in implementation");
}

#pragma mark - Private Methods

- (void)resumeDownloadTasks {
    for (CRVSessionTaskWrapper *wrapper in self.taskManager.downloadTaskWrappers) {
        
        __block NSURLSessionDownloadTask *task;
        
        //task can be resumed
        if ([wrapper isDownloadIncomplete] && [wrapper resumeData]) {
            
            task = [self downloadTaskWithResumeData:[wrapper resumeData] progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                return [self targetDirectoryByAppendingFileName:[response suggestedFilename]];
                
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                CRVSessionTaskWrapper *wrapper = [self.taskManager wrapperForTask:task];
                [self performAssetCompletionHandlerWithTask:task filePath:filePath error:error block:wrapper.downloadCompletionBlock];
            }];
            
        } else if (wrapper.task.state == NSURLSessionTaskStateCompleted){ //created new one
            
            NSURLRequest *request = wrapper.task.originalRequest;
            task = [self downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                return [self targetDirectoryByAppendingFileName:[response suggestedFilename]];
                
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                [self performAssetCompletionHandlerWithTask:task filePath:filePath error:error block:wrapper.downloadCompletionBlock];
            }];
        }
        
        if (task) {
            wrapper.task = task;
            [task resume];
        }
    }
}

- (void)performAssetCompletionHandlerWithTask:(NSURLSessionDownloadTask *)task filePath:(NSURL *)filePath error:(NSError *)error block:(CRVDownloadCompletionBlock)block {
    
    //number of retries exceeded:
    CRVSessionTaskWrapper *wrapper = [self.taskManager wrapperForTask:task];
    if (wrapper.reconnectionCount >= self.numberOfRetries) {
        CRVDownloadCompletionBlock block = wrapper.downloadCompletionBlock;
        if (block != NULL) block(nil, [self errorForRetriesLimitExceeded]);
        [self.taskManager removeDowloadTask:task];
        return;
    }
    
    //success:
    if (!error && block != NULL) {
        [self.taskManager removeDowloadTask:task];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:[filePath path]];
        block(data, nil);
    }
    
    //execute downloadAsset method once again after specified time:
}

- (void)cancelAllRequests {
    for (CRVSessionTaskWrapper *wrapper in self.taskManager.taskWrappers) {
        [wrapper.task cancel];
    }
}

- (NSError *)errorForEmptyFile {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Downloaded file is empty."};
    return [NSError errorWithDomain:CRVDomainErrorName code:0 userInfo:userInfo];
}

- (NSError *)errorForRetriesLimitExceeded {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Number of retries limit has been exceeded. Download failed"};
    return [NSError errorWithDomain:CRVDomainErrorName code:0 userInfo:userInfo];
}

- (NSURL *)targetDirectoryByAppendingFileName:(NSString *)name {
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:name]];
}

- (void)startMonitoringNetworkStatus {
    __weak typeof(self)weakSelf = self;
    [self.reachabilityManager startMonitoring];
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [weakSelf resumeDownloadTasks];
                break;
            default:
                break;
        }
    }];
}

@end
