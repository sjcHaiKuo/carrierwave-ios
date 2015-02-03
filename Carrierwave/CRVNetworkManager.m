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
#import "NSError+Carrierwave.h"

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

NSString *const CRVDomainErrorName = @"com.carrierwave.domain.network.error";
NSUInteger const CRVDefaultNumberOfRetries = 2;
NSTimeInterval const CRVDefaultReconnectionTime = 3;
NSString *const CRVDefaultPath = @"api/v1/attachments";

@interface CRVNetworkManager () <CRVSessionManagerDelegate, CRVWhitelistManagerDataSource>

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
        _whitelistManager = [[CRVWhitelistManager alloc] init];
        _whitelistManager.dataSource = self;
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
    NSURL *url = [NSURL URLWithString:[self URLString]];
    return [self uploadAsset:asset toURL:url progress:progress completion:completion];
}

- (NSString *)uploadAsset:(id<CRVAssetType>)asset toURL:(NSURL *)url progress:(CRVProgressBlock)progress completion:(CRVUploadCompletionBlock)completion {
    return [self.sessionManager uploadAssetRepresentedByDataStream:asset.dataStream withLength:asset.dataLength name:asset.fileName mimeType:asset.mimeType URLString:[url absoluteString] progress:^(double aProgress) {
            if (progress != NULL) progress(aProgress);
    } completion:^(NSDictionary *response, NSError *error) {
            if (completion != NULL) {
                CRVUploadInfo *info = error ? nil : [[CRVUploadInfo alloc] initWithDictionary:response];
                completion(info, error);
            }
    }];
}

- (NSString *)downloadAssetWithIdentifier:(NSString *)identifier progress:(CRVProgressBlock)progress completion:(CRVDownloadCompletionBlock)completion {
    NSParameterAssert(identifier);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/download", [self URLString], identifier]];
    return [self downloadAssetFromURL:url progress:progress completion:completion];
}

- (NSString *)downloadAssetFromURL:(NSURL *)url progress:(CRVProgressBlock)progress completion:(CRVDownloadCompletionBlock)completion {
    return [self.sessionManager downloadAssetFromURL:url.absoluteString progress:^(double aProgress) {
        if (progress != NULL) progress(aProgress);
    } completion:^(NSData *data, NSError *error) {
        if (completion != NULL) {
            CRVImageAsset *asset = (data.length > 0) ? [[CRVImageAsset alloc] initWithData:data] : nil;
            error = (!error && data && data.length == 0) ? [NSError crv_errorForEmptyFile] : error;
            completion(asset, error);
        }
    }];
}

- (void)deleteAssetWithIdentifier:(NSString *)identifier completion:(CRVCompletionBlock)completion {
    NSParameterAssert(identifier);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [self URLString], identifier]];
    [self deleteAssetFromURL:url completion:completion];
}

- (void)deleteAssetFromURL:(NSURL *)url completion:(CRVCompletionBlock)completion {
    NSParameterAssert(url);
    [self.sessionManager deleteAssetFromURL:url.absoluteString completion:^(BOOL success, NSError *error) {
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

#pragma mark - Private Methods

- (NSString *)URLString {
    NSAssert(self.serverURL != nil, @"Server URL cannot be nil.");
    return [self.serverURL URLByAppendingPathComponent:self.path].absoluteString;
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

#pragma mark - CRVWhitelistManagerDataSource

- (CRVSessionManager *)sessionManagerForWhitelistManager:(CRVWhitelistManager *)whitelistManager {
    return self.sessionManager;
}

- (NSString *)serverURLForWhitelistManager:(CRVWhitelistManager *)whitelistManager {
    return [self URLString];
}

@end
