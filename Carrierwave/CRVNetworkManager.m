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

@interface CRVNetworkManager ()

@property (strong, nonatomic) CRVSessionManager *sessionManager;

@end

@implementation CRVNetworkManager

#pragma mark - Object lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _sessionManager = [[CRVSessionManager alloc] init];
        self.numberOfRetries = CRVDefaultNumberOfRetries;
        self.reconnectionTime = CRVDefaultReconnectionTime;
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
    NSString *URLString = [self URLStringByAppendingPath:self.uploadPath];
    return [self.sessionManager uploadAssetRepresentedByDataStream:asset.dataStream
                                                        withLength:asset.dataLength
                                                              name:asset.fileName
                                                          mimeType:asset.mimeType
                                                         URLString:URLString
                                                          progress:^(double aProgress) {
        if (progress != NULL) progress(aProgress);
    } completion:^(BOOL success, NSError *error) {
        if (completion != NULL) completion(success, error);
    }];
}

- (NSString *)uploadAsset:(id<CRVAssetType>)asset toURL:(NSURL *)url progress:(CRVProgressBlock)progress completion:(CRVUploadCompletionBlock)completion {
    NSParameterAssert(url);
    return [self.sessionManager uploadAssetRepresentedByDataStream:asset.dataStream
                                                        withLength:asset.dataLength
                                                              name:asset.fileName
                                                          mimeType:asset.mimeType
                                                         URLString:[url absoluteString]
                                                          progress:^(double aProgress) {
        if (progress != NULL) progress(aProgress);
    } completion:^(BOOL success, NSError *error) {
        if (completion != NULL) completion(success, error);
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
    NSParameterAssert(url);
    return [self.sessionManager downloadAssetFromURL:url.absoluteString progress:^(double aProgress) {
        if (progress != NULL) progress(aProgress);
    } completion:^(NSData *data, NSError *error) {
        [self performDownloadCompletionBlock:completion withData:data error:error];
    }];
}

- (void)setShowsNetworkActivityIndicator:(BOOL)shows {
    if (_showsNetworkActivityIndicator != shows) {
        [AFNetworkActivityIndicatorManager sharedManager].enabled = shows;
        _showsNetworkActivityIndicator = shows;
    }
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

- (NSString *)URLStringByAppendingPath:(NSString *)path {
    NSAssert(self.serverURL != nil, @"Server URL cannot be nil.");
    return [self.serverURL URLByAppendingPathComponent:path].absoluteString;
}

- (void)performDownloadCompletionBlock:(CRVDownloadCompletionBlock)block withData:(NSData *)data error:(NSError *)error {
    if (block != NULL) {
        CRVImageAsset *asset = (data.length > 0) ? [[CRVImageAsset alloc] initWithData:data] : nil;
        error = (!error && data && data.length == 0) ? [self errorForEmptyFile] : error;
        block(asset, error);
    }
}

- (NSError *)errorForEmptyFile {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Downloaded file is empty."};
    return [NSError errorWithDomain:CRVDomainErrorName code:0 userInfo:userInfo];
}

@end
