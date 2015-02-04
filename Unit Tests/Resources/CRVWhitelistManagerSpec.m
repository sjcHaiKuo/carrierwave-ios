//
//  CRVWhitelistManagerSpec.m
//  Carrierwave
//
//  Created by Grzegorz Lesiak on 02/02/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVWhitelistManagerSpec)

fdescribe(@"CRVWhitelistManagerSpec", ^{
    
    __block CRVWhitelistManager *whitelistManager;
    
    describe(@"on initialization", ^{
        
        beforeEach(^{
            whitelistManager = [[CRVWhitelistManager alloc] init];
        });
        
        afterEach(^{
            whitelistManager = nil;
        });
        
        it(@"should set whitelist path to default", ^{
            expect(whitelistManager.whitelistPath).to.equal(CRVWhitelistDefaultPath);
        });
        
        it(@"should set whitelist validation time to default", ^{
            expect(whitelistManager.whitelistValidityTime).to.equal(CRVDefaultWhitelistValidity);
        });
    });
    
    describe(@"on loading", ^{
        
        beforeEach(^{
            // Save sample whitelist
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[NSDate new] forKey:@"CRVWhitelistDateKey"];
            [userDefaults setObject:@[@"one", @"two", @"three"] forKey:@"CRVWhitelistItemsKey"];
            [userDefaults synchronize];
            
            whitelistManager = [[CRVWhitelistManager alloc] init];
            [whitelistManager loadWhitelist];
        });
        
        afterEach(^{
            whitelistManager = nil;
        });
        
        it(@"should load whitelist", ^{
            expect([whitelistManager containsItem:@"one"]).to.beTruthy();
            expect([whitelistManager containsItem:@"two"]).to.beTruthy();
            expect([whitelistManager containsItem:@"three"]).to.beTruthy();
        });
    });
    
    pending(@"whitelist update");
    
    pending(@"whitelist synchronization");
    
});

SpecEnd
