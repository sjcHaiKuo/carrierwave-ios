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

NSTimeInterval const CRVDefaultWhitelistValidity = 111600;
NSString *const CRVWhitelistDefaultPath = @"/supported_extensions";
static NSString *const CRVWhitelistItemsKey = @"CRVWhitelistItemsKey";
static NSString *const CRVWhitelistDateKey = @"CRVWhitelistDateKey";

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

#pragma mark - Whitelist Loading

- (void)loadWhitelist {
    NSArray *whitelistArray = [[NSUserDefaults standardUserDefaults] arrayForKey:CRVWhitelistItemsKey];
    if (whitelistArray) {
        self.whitelistArray = whitelistArray;
    }
    [self updateWhitelist];
}

#pragma mark - Whitelist Updating

- (void)updateWhitelist {
    NSDate *whitelistDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:CRVWhitelistDateKey];
    if ([self isValidWhitelistWithDate:whitelistDate] || self.whitelistArray.count == 0) {
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
        [userDefaults setObject:self.whitelistArray forKey:CRVWhitelistItemsKey];
        [userDefaults setObject:[NSDate new] forKey:CRVWhitelistDateKey];
        [userDefaults synchronize];
    }
}

#pragma mark - Whitelist Fetching

- (void)fetchWhitelistWithCompletion:(CRVCompletionBlock)completion {
    if (completion == NULL) {
        return;
    }
    
    if (!self.dataSource) {
        completion(NO, [NSError crv_errorForEmptyDataSource]);
        return;
    }

    NSString *serverURL = [self.dataSource serverURLForWhitelistManager:self];
    CRVSessionManager *sessionManager = [self.dataSource sessionManagerForWhitelistManager:self];
    if (!serverURL || !sessionManager) {
        completion(NO, [NSError crv_errorForEmptyDataSource]);
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
            completion(YES, nil);
        } else {
            completion(NO, jsonError);
        }
    }];
}

#pragma mark - Whitelist Query

- (BOOL)containsMimeType:(NSString *)mimeType {
    mimeType = [[mimeType componentsSeparatedByString:@"/"] lastObject];
    if (!mimeType) {
        return NO;
    }
    __block BOOL isPresent = NO;
    [self.whitelistArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if ([mimeType isEqualToString:obj]) {
            isPresent = YES;
            *stop = YES;
        }
    }];
    return isPresent;
}

@end
