//
//  CRVHTTPSessionManager.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 05.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVHTTPSessionManager.h"

@interface CRVHTTPSessionManager ()

@end

@implementation CRVHTTPSessionManager

#pragma mark - Object lifecycle

- (instancetype)init {
    return [self initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super initWithSessionConfiguration:configuration];
    if (self) {
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

- (void)dealloc {
    [self cancelAllRequests];
}

#pragma mark - Public Methods

- (void)downloadTaskWithRequest:(NSURLRequest *)request completion:(void (^)(NSData *data, NSError *))completion {
    [[self dataTaskWithRequest:request completionHandler:^(__unused NSURLResponse *response, id responseObject, NSError *error) {
        if (completion != NULL) completion(responseObject, error);
    }] resume];
}

- (void)uploadAssetRepresentedByData:(NSData *)data withName:(NSString *)name mimeType:(NSString *)mimeType URLString:(NSString *)URLString completion:(void (^)(BOOL, NSError *))completion {
    
    NSError *error = nil;
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:URLString parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:name fileName:name mimeType:mimeType];
    } error:&error];
    
    [[self uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(__unused NSURLResponse *response, id responseObject, NSError *error) {
        
        if (completion != NULL) completion(error ? NO : YES, error);
    }] resume];
}

#pragma mark - Private Methods

- (void)cancelAllRequests {
    for (NSURLSessionTask *task in self.tasks) {
        [task cancel];
    }
}

@end
