//
//  CRVWhitelistManagerSpec.m
//  Carrierwave
//
//  Created by Grzegorz Lesiak on 02/02/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVWhitelistManagerSpec)

describe(@"CRVWhitelistManagerSpec", ^{
    
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
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:@"CRVWhitelistDateKey"];
            [userDefaults removeObjectForKey:@"CRVWhitelistItemsKey"];
            [userDefaults synchronize];
        });
        
        it(@"should load whitelist", ^{
            expect([whitelistManager containsMimeType:@"one"]).to.beTruthy();
            expect([whitelistManager containsMimeType:@"two"]).to.beTruthy();
            expect([whitelistManager containsMimeType:@"three"]).to.beTruthy();
        });
    });
    
    describe(@"on updating", ^{
        
        __block CRVNetworkManager *networkManager = nil;
        __block id<OHHTTPStubsDescriptor> stub;
        
        beforeAll(^{
            [Expecta setAsynchronousTestTimeout:2];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[NSDate new] forKey:@"CRVWhitelistDateKey"];
            [userDefaults setObject:@[@"one", @"two", @"three"] forKey:@"CRVWhitelistItemsKey"];
            [userDefaults synchronize];
            
            networkManager = [[CRVNetworkManager alloc] init];
            networkManager.reconnectionTime = 0.2;
            networkManager.numberOfRetries = 4;
            networkManager.serverURL = [NSURL URLWithString:@"http://www.example.com"];
            whitelistManager = networkManager.whitelistManager;
            
            stub = [OHHTTPStubs crv_stubWhitelistRequestWithError:CRVStubErrorNone manager:networkManager];
            whitelistManager.whitelistValidityTime = 0;
            [whitelistManager updateWhitelist];
        });
        
        afterAll(^{
            [OHHTTPStubs removeStub:stub];
            whitelistManager = nil;
            networkManager = nil;
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:@"CRVWhitelistDateKey"];
            [userDefaults removeObjectForKey:@"CRVWhitelistItemsKey"];
            [userDefaults synchronize];
        });
        
        it(@"should update the whitelist", ^{
            expect([whitelistManager containsMimeType:@"image/jpg"]).will.beTruthy();
            expect([whitelistManager containsMimeType:@"image/png"]).will.beTruthy();
            expect([whitelistManager containsMimeType:@"image/gif"]).will.beTruthy();
            expect([whitelistManager containsMimeType:@"one"]).will.beFalsy();
            expect([whitelistManager containsMimeType:@"two"]).will.beFalsy();
            expect([whitelistManager containsMimeType:@"three"]).will.beFalsy();
        });
        
        it(@"should synchronize the whitelist", ^{
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSArray *whitelistArray = [userDefaults objectForKey:@"CRVWhitelistItemsKey"];
            NSDate *whitelistDate = [userDefaults objectForKey:@"CRVWhitelistDateKey"];
            
            expect(whitelistDate).willNot.beNil();
            expect(whitelistArray).willNot.beNil();
            expect(whitelistArray).will.contain(@"jpg");
            expect(whitelistArray).will.contain(@"png");
            expect(whitelistArray).will.contain(@"gif");
            expect(whitelistArray).willNot.contain(@"one");
            expect(whitelistArray).willNot.contain(@"two");
            expect(whitelistArray).willNot.contain(@"three");
        });
        
    });

});

SpecEnd
