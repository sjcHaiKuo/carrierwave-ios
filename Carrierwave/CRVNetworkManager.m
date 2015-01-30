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

NSString *const CRVDomainErrorName = @"com.carrierwave.domain.network.error";
NSUInteger const CRVDefaultNumberOfRetries = 2;
NSTimeInterval const CRVDefaultReconnectionTime = 3;
NSTimeInterval const CRVDefaultWhitelistValidity = 111600;
NSString *const CRVDefaultPath = @"api/v1/attachments";
NSString *const CRVWebServiceWhitelist = @"/supported_extensions";
static NSString *const CRVWhitelistItems = @"CRVWhitelistItems";
static NSString *const CRVWhitelistDate = @"CRVWhitelistDate";

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
        _whitelistValidityTime = CRVDefaultWhitelistValidity;
        [self loadWhitelist];
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

- (void)loadWhitelist {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *whitelistArray = [userDefaults arrayForKey:CRVWhitelistItems];
    if (whitelistArray) {
        self.whitelistArray = whitelistArray;
    }
    [self updateWhitelist];
}

- (void)updateWhitelist {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *whitelistDate = (NSDate *)[userDefaults objectForKey:CRVWhitelistDate];
    if ([self isValidWhitelistWithDate:whitelistDate]) {
        [self fetchWhitelistWithCompletion:^(BOOL success, NSError *error) {
            if(success) {
                [self synchronizeWhitelist];
            } else {
                NSLog(@"Error fetching whitelist: %@", error);
            }
        }];
    }
}

- (BOOL)isValidWhitelistWithDate:(NSDate *)whitelistDate {
    return whitelistDate ? ([[whitelistDate dateByAddingTimeInterval:self.whitelistValidityTime] compare:[NSDate new]] == NSOrderedAscending) : NO;
}

- (void)synchronizeWhitelist {
    if (self.whitelistArray) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.whitelistArray forKey:CRVWhitelistItems];
        [userDefaults setObject:[NSDate new] forKey:CRVWhitelistDate];
        [userDefaults synchronize];
    }
}

#pragma mark - Public Methods

/**
 * Downloads whitelist of acceptable assets types
 *
 *  @param completion The completion block performed on server response.
 */
- (void)fetchWhitelistWithCompletion:(CRVCompletionBlock)completion {
    NSURL *assetsTypesURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self URLString], CRVWebServiceWhitelist]];
    [self.sessionManager downloadWhitelistFromURL:assetsTypesURL withCompletion:^(NSData *data, NSError *error) {
        if(error) {
            completion(NO,error);
        }
        NSError *jsonError;
        NSArray *assetsTypesArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        if(!jsonError) {
            self.whitelistArray = assetsTypesArray;
            completion(YES, nil);
        } else {
            completion(NO, jsonError);
        }
    }];
}

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
            error = (!error && data && data.length == 0) ? [self errorForEmptyFile] : error;
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

- (void)setShowsNetworkActivityIndicator:(BOOL)shows {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = shows;
    _showsNetworkActivityIndicator = shows;
}

#pragma mark - Private Methods

- (NSString *)URLString {
    NSAssert(self.serverURL != nil, @"Server URL cannot be nil.");
    return [self.serverURL URLByAppendingPathComponent:self.path].absoluteString;
}

- (NSError *)errorForEmptyFile {
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Downloaded file is empty." };
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
