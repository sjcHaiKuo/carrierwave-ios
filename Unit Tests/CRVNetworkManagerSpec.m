//
//  CRVNetworkManagerSpec.m
//
//  Copyright 2015 Netguru Sp. z o.o. All rights reserved.
//

static NSString * const CRVImageIdentifier = @"1";

typedef void (^CRVRemoveTmpDirectoryContent)();

SpecBegin(CRVNetworkManagerSpec)

describe(@"CRVNetworkManagerSpec", ^{
    
    __block CRVNetworkManager *manager = nil;
    
    CRVRemoveTmpDirectoryContent removeTmpDirectoryContent = ^void() {
        NSFileManager *manager = [NSFileManager defaultManager];
        for (NSString *file in [manager contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL]) {
            [manager removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
        };
    };
    
    beforeAll(^{
        removeTmpDirectoryContent();
    });
    
    beforeEach(^{
        manager = [[CRVNetworkManager alloc] init];
    });
    
    afterEach(^{
        manager = nil;
    });
    
    afterAll(^{
        removeTmpDirectoryContent();
    });
    
    describe(@"when newly created", ^{
        
        it(@"should have no server url.", ^{
            expect(manager.serverURL).to.beNil();
        });
        
        it(@"should have upload path equal to default value.", ^{
            expect(manager.path).to.equal(CRVDefaultPath);
        });
        
        it(@"should check cache.", ^{
            expect(manager.checkCache).to.beTruthy();
        });
        
        it(@"should number of retries be set to default value.", ^{
            expect(manager.numberOfRetries).to.equal(CRVDefaultNumberOfRetries);
        });
        
        it(@"should reconnection time be set to default value.", ^{
            expect(manager.reconnectionTime).to.equal(CRVDefaultReconnectionTime);
        });
        
        it(@"should conform CRVSessionManagerDelegate.", ^{
            expect(manager).conformTo(@protocol(CRVSessionManagerDelegate));
        });
        
        it(@"should respond to check cache delegate.", ^{
            expect(manager).to.respondTo(@selector(shouldSessionMangerCheckCache:));
        });
        
        it(@"should respond to number of retries delegate.", ^{
            expect(manager).to.respondTo(@selector(numberOfRetriesSessionManagerShouldPrepare:));
        });
        
        it(@"should respond to reconnection time delegate.", ^{
            expect(manager).to.respondTo(@selector(reconnectionTimeSessionManagerShouldWait:));
        });
        
        it(@"should conform CRVWhitelistManagerDataSource.", ^{
            expect(manager).conformTo(@protocol(CRVWhitelistManagerDataSource));
        });
    });
    
    describe(@"when using a shared instance", ^{
        
        it(@"should return the same instance.", ^{
            CRVNetworkManager *first = [CRVNetworkManager sharedManager];
            CRVNetworkManager *second = [CRVNetworkManager sharedManager];
            expect(first).to.beIdenticalTo(second);
        });
    });
    
    describe(@"with no provided url", ^{
        
        it(@"when downloading should raise an exception.", ^{
            expect(^{
                [manager downloadAssetFromURL:nil progress:nil completion:nil];
            }).to.raise(NSInternalInconsistencyException);
        });
        
        it(@"when uploading should raise an exception.", ^{
            expect(^{
                [manager uploadAsset:nil progress:nil completion:nil];
            }).to.raise(NSInternalInconsistencyException);
        });
        
        it(@"when deleting should raise an exception.", ^{
            expect(^{
                [manager deleteAssetFromURL:nil completion:nil];
            }).to.raise(NSInternalInconsistencyException);
        });
    });
    
    describe(@"with no provided identifier", ^{
        
        beforeEach(^{
            manager.serverURL = [NSURL URLWithString:@"http://www.example.com"];
        });
        
        it(@"when downloading should raise an exception.", ^{
            expect(^{
                [manager downloadAssetWithIdentifier:nil progress:nil completion:nil];
            }).to.raise(NSInternalInconsistencyException);
        });
        
        it(@"when uploading should raise an exception.", ^{
            expect(^{
                [manager uploadAsset:nil progress:nil completion:nil];
            }).to.raise(NSInternalInconsistencyException);
        });
        
        it(@"when deleting should raise an exception.", ^{
            expect(^{
                [manager deleteAssetWithIdentifier:nil completion:nil];
            }).to.raise(NSInternalInconsistencyException);
        });
    });
    
    describe(@"when dowloading", ^{
        
        NSString *filePath = [[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", CRVImageIdentifier]]] path];
        NSURL *anyURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.example.com/%@/download", CRVImageIdentifier]];
        __block id<OHHTTPStubsDescriptor> stub = nil;
        __block CRVImageAsset *anAsset = nil;
        __block NSError *anError = nil;
        
        beforeAll(^{
            [[NSData crv_defaultImageDataRepresentation] writeToFile:filePath atomically:YES];
        });
        
        afterAll(^{
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
        });
        
        beforeEach(^{
            manager.reconnectionTime = 0.2;
            manager.numberOfRetries = 4;
            manager.serverURL = [NSURL URLWithString:@"http://www.example.com"];
            [Expecta setAsynchronousTestTimeout:(manager.reconnectionTime * manager.numberOfRetries + 0.5)];
            anAsset = nil;
            anError = nil;
        });
        
        context(@"and checking cache", ^{
            
            beforeEach(^{
                manager.checkCache = YES;
            });
            
            it(@"should succeed without connection.", ^{
                [manager downloadAssetFromURL:anyURL progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
                    anError = error;
                    anAsset = asset;
                    expect([OHHTTPStubs retriesMade]).to.equal(0);
                }];
            
                expect(anError).will.beNil();
                expect(anAsset).will.notTo.beNil();
                expect(anAsset.dataLength).will.equal([NSData crv_defaultImageDataRepresentation].length);
            });
            
            it(@"should succeed without connection.", ^{
                [manager downloadAssetWithIdentifier:CRVImageIdentifier progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
                    anError = error;
                    anAsset = asset;
                    expect([OHHTTPStubs retriesMade]).to.equal(0);
                }];
                
                expect(anError).will.beNil();
                expect(anAsset).will.notTo.beNil();
                expect(anAsset.dataLength).will.equal([NSData crv_defaultImageDataRepresentation].length);
            });
        });
        
        context(@"without checking cache", ^{
            
            beforeEach(^{
                manager.checkCache = NO;
            });
            
            context(@"without retries", ^{
                
                beforeEach(^{
                    stub = [OHHTTPStubs crv_stubDownloadRequestWithError:CRVStubErrorNone manager:manager];
                });
                
                afterEach(^{
                    [OHHTTPStubs removeStub:stub];
                });
                
                it(@"should succeed.", ^{
                    [manager downloadAssetFromURL:anyURL progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
                        anError = error;
                        anAsset = asset;
                        expect([OHHTTPStubs retriesMade]).to.equal(0);
                    }];
                    
                    expect(anError).will.beNil();
                    expect(anAsset).will.notTo.beNil();
                    expect(anAsset.dataLength).will.equal([NSData crv_defaultImageDataRepresentation].length);
                });
                
                it(@"should succeed.", ^{
                    [manager downloadAssetWithIdentifier:CRVImageIdentifier progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
                        anError = error;
                        anAsset = asset;
                        expect([OHHTTPStubs retriesMade]).to.equal(0);
                    }];
                    
                    expect(anError).will.beNil();
                    expect(anAsset).will.notTo.beNil();
                    expect(anAsset.dataLength).will.equal([NSData crv_defaultImageDataRepresentation].length);
                });
            });
            
            context(@"with retries limit", ^{
                
                beforeEach(^{
                    stub = [OHHTTPStubs crv_stubDownloadRequestWithError:CRVStubErrorRetriesLimitReached manager:manager];
                });
                
                afterEach(^{
                    [OHHTTPStubs removeStub:stub];
                });
                
                it(@"should succeed.", ^{
                    [manager downloadAssetFromURL:anyURL progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
                        anError = error;
                        anAsset = asset;
                        expect([OHHTTPStubs retriesMade]).to.equal(manager.numberOfRetries);
                    }];
                    
                    expect(anError).will.beNil();
                    expect(anAsset).will.notTo.beNil();
                    expect(anAsset.dataLength).will.equal([NSData crv_defaultImageDataRepresentation].length);
                });
                
                it(@"should succeed.", ^{
                    [manager downloadAssetWithIdentifier:CRVImageIdentifier progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
                        anError = error;
                        anAsset = asset;
                        expect([OHHTTPStubs retriesMade]).to.equal(manager.numberOfRetries);
                    }];
                    
                    expect(anError).will.beNil();
                    expect(anAsset).will.notTo.beNil();
                    expect(anAsset.dataLength).will.equal([NSData crv_defaultImageDataRepresentation].length);
                });
            });
            
            context(@"with retries limit exceeded", ^{
                
                beforeEach(^{
                    stub = [OHHTTPStubs crv_stubDownloadRequestWithError:CRVStubErrorRetriesLimitExceeded manager:manager];
                });
                
                afterEach(^{
                    [OHHTTPStubs removeStub:stub];
                });
                
                it(@"should fail.", ^{
                    [manager downloadAssetFromURL:anyURL progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
                        anError = error;
                        anAsset = asset;
                        expect([OHHTTPStubs retriesMade]).to.equal(manager.numberOfRetries + 1);
                    }];
                    
                    expect(anError).will.notTo.beNil();
                    expect(anAsset).will.beNil();
                });
                
                it(@"should fail.", ^{
                    [manager downloadAssetWithIdentifier:CRVImageIdentifier progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
                        anError = error;
                        anAsset = asset;
                        expect([OHHTTPStubs retriesMade]).to.equal(manager.numberOfRetries + 1);
                    }];
                    
                    expect(anError).will.notTo.beNil();
                    expect(anAsset).will.beNil();
                });
            });
        });
    });
    
    describe(@"when deleting", ^{
        
        __block id<OHHTTPStubsDescriptor> stub = nil;
        __block NSError *anError;
        __block BOOL aSuccess;
        
        beforeEach(^{
            manager = [[CRVNetworkManager alloc] init];
            manager.reconnectionTime = 0.2;
            manager.numberOfRetries = 4;
            manager.serverURL = [NSURL URLWithString:@"http://www.example.com"];
            [Expecta setAsynchronousTestTimeout:(manager.reconnectionTime * manager.numberOfRetries + 0.5)];
            anError = nil;
        });
    
        context(@"without retries", ^{
            
            beforeEach(^{
                stub = [OHHTTPStubs crv_stubDeletionRequestWithError:CRVStubErrorNone manager:manager];
                aSuccess = NO;
            });
            
            afterEach(^{
                [OHHTTPStubs removeStub:stub];
            });
            
            it(@"should succeed.", ^{
                [manager deleteAssetWithIdentifier:@"1" completion:^(BOOL success, NSError *error) {
                    aSuccess = success;
                    anError = error;
                    expect([OHHTTPStubs retriesMade]).to.equal(0);
                }];
                
                expect(anError).will.beNil();
                expect(aSuccess).will.beTruthy();
            });
            
            it(@"should succeed.", ^{
                [manager deleteAssetFromURL:[NSURL URLWithString:@"http://www.example.com"] completion:^(BOOL success, NSError *error) {
                    aSuccess = success;
                    anError = error;
                    expect([OHHTTPStubs retriesMade]).to.equal(0);
                }];
                
                expect(anError).will.beNil();
                expect(aSuccess).will.beTruthy();
            });
        });
        
        context(@"with retries limit", ^{
            
            beforeEach(^{
                stub = [OHHTTPStubs crv_stubDeletionRequestWithError:CRVStubErrorRetriesLimitReached manager:manager];
                aSuccess = NO;
            });
            
            afterEach(^{
                [OHHTTPStubs removeStub:stub];
            });
            
            it(@"should succeed.", ^{
                [manager deleteAssetWithIdentifier:@"1" completion:^(BOOL success, NSError *error) {
                    aSuccess = success;
                    anError = error;
                    expect([OHHTTPStubs retriesMade]).to.equal(manager.numberOfRetries);
                }];
                
                expect(anError).will.beNil();
                expect(aSuccess).will.beTruthy();
            });
            
            it(@"should succeed.", ^{
                [manager deleteAssetFromURL:[NSURL URLWithString:@"http://www.example.com"] completion:^(BOOL success, NSError *error) {
                    aSuccess = success;
                    anError = error;
                    expect([OHHTTPStubs retriesMade]).to.equal(manager.numberOfRetries);
                }];
                
                expect(anError).will.beNil();
                expect(aSuccess).will.beTruthy();
            });
        });
        
        context(@"with retries limit exceeded", ^{
            
            beforeEach(^{
                stub = [OHHTTPStubs crv_stubDeletionRequestWithError:CRVStubErrorRetriesLimitExceeded manager:manager];
                aSuccess = YES;
            });
            
            afterEach(^{
                [OHHTTPStubs removeStub:stub];
            });
            
            it(@"should fail.", ^{
                [manager deleteAssetWithIdentifier:@"1" completion:^(BOOL success, NSError *error) {
                    aSuccess = success;
                    anError = error;
                    expect([OHHTTPStubs retriesMade]).to.equal(manager.numberOfRetries + 1);
                }];
                
                expect(anError).will.toNot.beNil();
                expect(aSuccess).will.beFalsy();
            });
            
            it(@"should fail.", ^{
                [manager deleteAssetFromURL:[NSURL URLWithString:@"http://www.example.com"] completion:^(BOOL success, NSError *error) {
                    aSuccess = success;
                    anError = error;
                    expect([OHHTTPStubs retriesMade]).to.equal(manager.numberOfRetries + 1);
                }];
                
                expect(anError).will.toNot.beNil();
                expect(aSuccess).will.beFalsy();
            });
        });
    });
    
    //OHHTTPStubs doesn't simulate data upload. Test for this stub has been omited.
});

SpecEnd
