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

@interface CRVNetworkManager ()

@property (strong, nonatomic) CRVSessionManager *sessionManager;

@end

#pragma mark -

@implementation CRVNetworkManager

#pragma mark - Object lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _sessionManager = [[CRVSessionManager alloc] init];
        self.numberOfRetries = 0;
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

- (void)uploadAsset:(id<CRVAssetType>)asset progress:(CRVProgressBlock)progress completion:(CRVUploadCompletionBlock)completion {
    NSString *URLString = [self URLStringByAppendingPath:self.uploadPath];
    [self.sessionManager uploadAssetRepresentedByData:asset.data withName:asset.fileName mimeType:asset.mimeType URLString:URLString progress:^(double aProgress) {
        if (progress != NULL) progress(aProgress);
    } completion:^(BOOL success, NSError *error) {
        if (completion != NULL) completion(success, error);
    }];
}

- (void)uploadAsset:(id<CRVAssetType>)asset toURL:(NSURL *)url progress:(CRVProgressBlock)progress completion:(CRVUploadCompletionBlock)completion {
    [self.sessionManager uploadAssetRepresentedByData:asset.data withName:asset.fileName mimeType:asset.mimeType URLString:[url absoluteString] progress:^(double aProgress) {
        if (progress != NULL) progress(aProgress);
    } completion:^(BOOL success, NSError *error) {
        if (completion != NULL) completion(success, error);
    }];
}

- (void)downloadAssetFromPath:(NSString *)path progress:(CRVProgressBlock)progress completion:(CRVDownloadCompletionBlock)completion {
    [self.sessionManager downloadAssetFromURL:[self URLStringByAppendingPath:path] progress:^(double aProgress) {
        if (progress != NULL) progress(aProgress);
    } completion:^(NSData *data, NSError *error) {
        [self performDownloadCompletionBlock:completion withData:data error:error];
    }];
}

- (void)downloadAssetFromURL:(NSURL *)url progress:(CRVProgressBlock)progress completion:(CRVDownloadCompletionBlock)completion {
    [self.sessionManager downloadAssetFromURL:url.absoluteString progress:^(double aProgress) {
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

#pragma mark - Accessors

- (void)setNumberOfRetries:(NSUInteger)numberOfRetries {
    self.sessionManager.numberOfRetries = numberOfRetries;
}

- (NSUInteger)numberOfRetries {
    return self.sessionManager.numberOfRetries;
}

#pragma mark - Private Methods

- (NSString *)URLStringByAppendingPath:(NSString *)path {
    NSAssert(self.serverURL != nil, @"Server URL cannot be nil.");
    return [self.serverURL URLByAppendingPathComponent:path].absoluteString;
}

- (void)performDownloadCompletionBlock:(CRVDownloadCompletionBlock)block withData:(NSData *)data error:(NSError *)error {
    if (block != NULL) {
        CRVImageAsset *asset = (data.length > 0) ? [[CRVImageAsset alloc] initWithData:data] : nil;
        block(asset, error);
    }
}

@end
