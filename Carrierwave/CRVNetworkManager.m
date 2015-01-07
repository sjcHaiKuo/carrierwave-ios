//
//  CRVUploadManager.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 05.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVNetworkManager.h"
#import "CRVHTTPSessionManager.h"
#import "CRVAssetType.h"
#import "CRVImageAsset.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

@interface CRVNetworkManager ()

@property (strong, nonatomic) CRVHTTPSessionManager *sessionManager;

@end

#pragma mark -

@implementation CRVNetworkManager

#pragma mark - Object lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _sessionManager = [[CRVHTTPSessionManager alloc] init];
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

- (void)uploadAsset:(id<CRVAssetType>)asset completion:(CRVUploadCompletionBlock)completion {
    NSAssert(self.serverURL != nil, @"Server URL cannot be nil.");
    NSString *url;
    [self.sessionManager uploadAssetRepresentedByData:asset.data withName:asset.fileName mimeType:asset.mimeType URLString:url completion:^(BOOL success, NSError *error) {
        if (completion != NULL) completion(success, error);
    }];
}

- (void)uploadAsset:(id<CRVAssetType>)asset onURL:(NSURL *)url completion:(CRVUploadCompletionBlock)completion {
    [self.sessionManager uploadAssetRepresentedByData:asset.data withName:asset.fileName mimeType:asset.mimeType URLString:[url absoluteString] completion:^(BOOL success, NSError *error) {
        if (completion != NULL) completion(success, error);
    }];
}

- (void)downloadAssetFromPath:(NSString *)path completion:(CRVDownloadCompletionBlock)completion {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self absoluteURLStringForPath:path]]];
    [self.sessionManager downloadTaskWithRequest:request completion:^(NSData *data, NSError *error) {
        [self performDownloadCompletionBlock:completion withData:data error:error];
    }];
}

- (void)downloadAssetFromURL:(NSURL *)url completion:(CRVDownloadCompletionBlock)completion {
    NSAssert(self.serverURL != nil, @"Server URL cannot be nil.");
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.sessionManager downloadTaskWithRequest:request completion:^(NSData *data, NSError *error) {
        [self performDownloadCompletionBlock:completion withData:data error:error];
    }];
}

- (void)setShowsNetworkActivityIndicator:(BOOL)shows {
    if (_showsNetworkActivityIndicator != shows) {
        [AFNetworkActivityIndicatorManager sharedManager].enabled = shows;
        _showsNetworkActivityIndicator = shows;
    }
}
    
#pragma mark - Private Methods

- (NSString *)absoluteURLStringForPath:(NSString *)path {
    NSAssert(self.serverURL != nil, @"Server URL cannot be nil.");
    return [self.serverURL URLByAppendingPathComponent:path].absoluteString;
}

- (void)performDownloadCompletionBlock:(CRVDownloadCompletionBlock)block withData:(NSData *)data error:(NSError *)error {
    if (block != NULL) {
        CRVImageAsset *asset = [[CRVImageAsset alloc] initWithData:data];
        block(asset, error);
    }
}

@end
