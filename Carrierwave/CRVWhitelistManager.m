//
//  CRVWhitelistManager.m
//  Carrierwave
//
//  Created by Grzegorz Lesiak on 30/01/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVWhitelistManager.h"
#import "CRVNetworkTypedefs.h"
#import "CRVSessionManager.h"
#import "NSError+Carrierwave.h"

static NSTimeInterval const CRVDefaultWhitelistValidity = 111600;
static NSString *const CRVWhitelistDefaultPath = @"/supported_extensions";
static NSString *const CRVWhitelistItems = @"CRVWhitelistItems";
static NSString *const CRVWhitelistDate = @"CRVWhitelistDate";

@interface CRVWhitelistManager ()

@property (strong, nonatomic) NSArray *whitelistArray;

@end

@implementation CRVWhitelistManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.whitelistPath = CRVWhitelistDefaultPath;
        self.whitelistValidityTime = CRVDefaultWhitelistValidity;
        self.whitelistArray = [NSArray array];
    }
    return self;
}

#pragma mark - Custom Setter

- (void)setDataSource:(id<CRVWhitelistManagerDataSource>)dataSource {
    if (!dataSource) {
        _dataSource = dataSource;
        [self loadWhitelist];
    }
}

#pragma mark - Whitelist Loading

- (void)loadWhitelist {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *whitelistArray = [userDefaults arrayForKey:CRVWhitelistItems];
    if (whitelistArray) {
        self.whitelistArray = whitelistArray;
    }
    [self updateWhitelist];
}

#pragma mark - Whitelist Updating

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

#pragma mark - Whitelist Synchronization

- (void)synchronizeWhitelist {
    if (self.whitelistArray) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.whitelistArray forKey:CRVWhitelistItems];
        [userDefaults setObject:[NSDate new] forKey:CRVWhitelistDate];
        [userDefaults synchronize];
    }
}

#pragma mark - Whitelist Fetching

- (void)fetchWhitelistWithCompletion:(CRVCompletionBlock)completion {
    if (!self.dataSource) {
        if (completion != NULL) {
            completion(NO, [self errorForEmptyDataSource]);
        }
        return;
    }

    NSString *serverURL = [self.dataSource serverURLForWhitelistManager:self];
    CRVSessionManager *sessionManager = [self.dataSource sessionManagerForWhitelistManager:self];
    if (!serverURL || !sessionManager) {
        if (completion != NULL) {
            completion(NO, [self errorForEmptyDataSource]);
        }
        return;
    }

    NSURL *whitelistURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", serverURL, self.whitelistPath]];
    [sessionManager downloadWhitelistFromURL:whitelistURL completion:^(NSData *data, NSError *error) {
        if(error) {
            completion(NO,error);
        }
        NSError *jsonError;
        NSArray *assetsTypesArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        if (assetsTypesArray) {
            self.whitelistArray = assetsTypesArray;
            if (completion != NULL) {
                completion(YES, nil);
            }
        } else {
            if(completion != NULL) {
                completion(NO, jsonError);
            }
        }
    }];
}

- (NSError *)errorForEmptyDataSource {
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Whitelist needs a data source to be set and valid." };
    return [NSError crv_errorWithCode:CRVErrorWhitelistEmptyDataSource userInfo:userInfo];
}

#pragma mark - Whitelist Query

- (BOOL)containsItem:(NSString *)item {
    if (!item) {
        return NO;
    }
    __block BOOL isPresent = NO;
    [self.whitelistArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if ([item isEqualToString:obj]) {
            isPresent = YES;
            *stop = YES;
        }
    }];
    return isPresent;
}

@end
