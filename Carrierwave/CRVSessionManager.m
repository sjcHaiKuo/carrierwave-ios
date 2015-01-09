//
//  CRVHTTPSessionManager.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 05.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionManager.h"
#import "NSURLSessionTask+Category.h"

NSString * const CRVNetworkDomainName = @"com.carrierwave.network.domain.error";

typedef void (^CRVProgressBlockForTask)(NSURLSessionTask *);

@interface CRVSessionManager ()

@property (strong, nonatomic) NSMutableDictionary *mutableProgressBlockKeyedByTaskIdentifier;

@end

@implementation CRVSessionManager

#pragma mark - Object lifecycle

- (instancetype)init {
    return [self initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super initWithSessionConfiguration:configuration];
    if (self) {
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        _mutableProgressBlockKeyedByTaskIdentifier = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    [self cancelAllRequests];
}

#pragma mark - Public Methods

- (void)downloadAssetFromURL:(NSString *)URLString progress:(void (^)(double))progress completion:(void (^)(NSData *, NSError *))completion {

    __block NSURLSessionDataTask *task = [self dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLString]] completionHandler:^(NSURLResponse *response, NSData *responseObject, NSError *error) {
        
        [self.mutableProgressBlockKeyedByTaskIdentifier removeObjectForKey:@(task.taskIdentifier)];
        if ([responseObject length] == 0 && !error) {
            error = [self errorForEmptyFile];
        }
        if (completion != NULL) completion(responseObject, error);
    }];
    
    self.mutableProgressBlockKeyedByTaskIdentifier[@(task.taskIdentifier)] = ^(NSURLSessionTask *aTask) {
        if (progress != NULL) progress([aTask crv_dowloadProgress]);
    };
    
    __weak typeof(self)weakSelf = self;
    [self setDataTaskDidReceiveDataBlock:^(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data) {
        [weakSelf invokeProgressBlockFromTask:task];
    }];
    
    [task resume];
}

- (void)uploadAssetRepresentedByData:(NSData *)data withName:(NSString *)name mimeType:(NSString *)mimeType URLString:(NSString *)URLString progress:(void (^)(double))progress completion:(void (^)(BOOL, NSError *))completion {
    
    NSString *argNameOnServer = @"uploadedfile";

    NSURLSessionDataTask *task = [self POST:URLString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:argNameOnServer fileName:name mimeType:mimeType];
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [self.mutableProgressBlockKeyedByTaskIdentifier removeObjectForKey:@(task.taskIdentifier)];
        if (completion != NULL) completion(YES, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.mutableProgressBlockKeyedByTaskIdentifier removeObjectForKey:@(task.taskIdentifier)];
        if (completion != NULL) completion(NO, error);
    }];
    
    self.mutableProgressBlockKeyedByTaskIdentifier[@(task.taskIdentifier)] = ^(NSURLSessionTask *aTask) {
        if (progress != NULL) progress([aTask crv_uploadProgress]);
    };
    
    __weak typeof(self)weakSelf = self;
    [self setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        [weakSelf invokeProgressBlockFromTask:task];
    }];
    
    [task resume];
}

#pragma mark - Private Methods

- (void)invokeProgressBlockFromTask:(NSURLSessionTask *)task {
    CRVProgressBlockForTask progressBlock = self.mutableProgressBlockKeyedByTaskIdentifier[@(task.taskIdentifier)];
    if (progressBlock != NULL) progressBlock(task);
}

- (void)cancelAllRequests {
    for (NSURLSessionTask *task in self.tasks) {
        [task cancel];
    }
}

- (NSError *)errorForEmptyFile {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Downloaded file is empty."};
    return [NSError errorWithDomain:CRVNetworkDomainName code:0 userInfo:userInfo];
}

@end
