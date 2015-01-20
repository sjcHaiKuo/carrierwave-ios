//
//  CRVUploadManager.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 05.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVNetworkManager.h"
#import "CRVSessionManager.h"
#import "CRVAssetType.h"
#import "CRVImageAsset.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

NSString * const CRVDomainErrorName = @"com.carrierwave.domain.network.error";
NSUInteger const CRVDefaultNumberOfRetries = 2;
NSTimeInterval const CRVDefaultReconnectionTime = 3;
NSString * const CRVDefaultPath = @"api/v1/attachments";

@interface CRVNetworkManager () <CRVSessionManagerDelegate>

@property (strong, nonatomic) CRVSessionManager *sessionManager;

@end

@implementation CRVNetworkManager

#pragma mark - Object lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _sessionManager = [[CRVSessionManager alloc] init];
        _sessionManager.delegate = self;
        _checkCache = YES;
        _path = CRVDefaultPath;
        _numberOfRetries = CRVDefaultNumberOfRetries;
        _reconnectionTime = CRVDefaultReconnectionTime;
    }
    return self;
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static CRVNetworkManager *sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

#pragma mark - Public Methods

- (NSString *)uploadAsset:(id<CRVAssetType>)asset progress:(CRVProgressBlock)progress completion:(CRVUploadCompletionBlock)completion {
    NSString *URLString = [self URLStringByAppendingPath:self.path];
    return [self.sessionManager uploadAssetRepresentedByDataStream:asset.dataStream
                                                        withLength:asset.dataLength
                                                              name:asset.fileName
                                                          mimeType:asset.mimeType
                                                         URLString:URLString
                                                          progress:^(double aProgress) {
        if (progress != NULL) progress(aProgress);
    } completion:^(NSDictionary *response, NSError *error) {
        [self performUploadCompletionBlock:completion withResponse:response error:error];
    }];
}

- (NSString *)uploadAsset:(id<CRVAssetType>)asset toURL:(NSURL *)url progress:(CRVProgressBlock)progress completion:(CRVUploadCompletionBlock)completion {
    return [self.sessionManager uploadAssetRepresentedByDataStream:asset.dataStream
                                                        withLength:asset.dataLength
                                                              name:asset.fileName
                                                          mimeType:asset.mimeType
                                                         URLString:[url absoluteString]
                                                          progress:^(double aProgress) {
        if (progress != NULL) progress(aProgress);
    } completion:^(NSDictionary *response, NSError *error) {
        [self performUploadCompletionBlock:completion withResponse:response error:error];
    }];
}

- (NSString *)downloadAssetFromPath:(NSString *)path progress:(CRVProgressBlock)progress completion:(CRVDownloadCompletionBlock)completion {
    return [self.sessionManager downloadAssetFromURL:[self URLStringByAppendingPath:path] progress:^(double aProgress) {
        if (progress != NULL) progress(aProgress);
    } completion:^(NSData *data, NSError *error) {
        [self performDownloadCompletionBlock:completion withData:data error:error];
    }];
}

- (NSString *)downloadAssetFromURL:(NSURL *)url progress:(CRVProgressBlock)progress completion:(CRVDownloadCompletionBlock)completion {
    return [self.sessionManager downloadAssetFromURL:url.absoluteString progress:^(double aProgress) {
        if (progress != NULL) progress(aProgress);
    } completion:^(NSData *data, NSError *error) {
        [self performDownloadCompletionBlock:completion withData:data error:error];
    }];
}

- (void)deleteAssetWithIdentifier:(NSString *)identifier completion:(CRVCompletionBlock)completion {
    NSURL *url = [NSURL URLWithString:[self URLStringByAppendingPath:self.path]];
    [self deleteAssetWithIdentifier:identifier fromURL:url completion:completion];
}

- (void)deleteAssetWithIdentifier:(NSString *)identifier fromURL:(NSURL *)url completion:(CRVCompletionBlock)completion {
    NSParameterAssert(identifier); NSParameterAssert(url);
    NSString *URLString = [NSString stringWithFormat:@"%@/%@", [url absoluteString], identifier];
    [self.sessionManager deleteAssetFromURL:URLString completion:^(BOOL success, NSError *error) {
        if (completion != NULL) completion(success, error);
    }];
}

- (void)cancelProccessWithIdentifier:(NSString *)identifier {
    [self.sessionManager cancelProccessWithIdentifier:identifier];
}

- (void)pauseProccessWithIdentifier:(NSString *)identifier {
    [self.sessionManager pauseProccessWithIdentifier:identifier];
}

- (void)resumeProccessWithIdentifier:(NSString *)identifier {
    [self.sessionManager resumeProccessWithIdentifier:identifier];
}

- (void)setShowsNetworkActivityIndicator:(BOOL)shows {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = shows;
    _showsNetworkActivityIndicator = shows;
}

#pragma mark - Private Methods

- (NSString *)URLStringByAppendingPath:(NSString *)path {
    NSAssert(self.serverURL != nil, @"Server URL cannot be nil.");
    NSAssert(path != nil, @"Path cannot be nil.");
    return [self.serverURL URLByAppendingPathComponent:path].absoluteString;
}

- (void)performDownloadCompletionBlock:(CRVDownloadCompletionBlock)block withData:(NSData *)data error:(NSError *)error {
    if (block != NULL) {
        CRVImageAsset *asset = (data.length > 0) ? [[CRVImageAsset alloc] initWithData:data] : nil;
        error = (!error && data && data.length == 0) ? [self errorForEmptyFile] : error;
        block(asset, error);
    }
}

- (void)performUploadCompletionBlock:(CRVUploadCompletionBlock)block withResponse:(NSDictionary *)response error:(NSError *)error {
    CRVUploadInfo *info = error ? nil : [[CRVUploadInfo alloc] initWithDictionary:response];
    if (block != NULL) block(info, error);
}

- (NSError *)errorForEmptyFile {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Downloaded file is empty."};
    return [NSError errorWithDomain:CRVDomainErrorName code:0 userInfo:userInfo];
}

#pragma mark - CRVSessionManagerDelegate Methods

- (BOOL)shouldSessionMangerCheckCache:(CRVSessionManager *)manager {
    return self.checkCache;
}

- (NSTimeInterval)reconnectionTimeSessionManagerShouldWait:(CRVSessionManager *)manager {
    return self.reconnectionTime;
}

- (NSUInteger)numberOfRetriesSessionManagerShouldPrepare:(CRVSessionManager *)manager {
    return self.numberOfRetries;
}

@end
