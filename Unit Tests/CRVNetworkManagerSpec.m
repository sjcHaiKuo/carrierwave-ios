//
//  CRVNetworkManagerSpec.m
//
//  Copyright 2015 Netguru Sp. z o.o. All rights reserved.
//

#define kImageIdentifier @"1"
typedef void (^CRVRemoveTmpDirectoryContent)();

SpecBegin(CRVNetworkManagerSpec)

describe(@"CRVNetworkManagerSpec", ^{
    
    __block CRVNetworkManager *sut = nil;
    
    CRVRemoveTmpDirectoryContent removeTmpDirectoryContent = ^void() {
        NSFileManager *manager = [NSFileManager defaultManager];
        for (NSString *file in [manager contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL]) {
            [manager removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
        };
    };
    
    beforeAll(^{
        removeTmpDirectoryContent();
    });
    
    afterAll(^{
        removeTmpDirectoryContent();
    });
    
    describe(@"when newly created", ^{
        
        beforeEach(^{
            sut = [[CRVNetworkManager alloc] init];
        });
        
        afterEach(^{
            sut = nil;
        });
        
        it(@"should have no server url.", ^{
            expect(sut.serverURL).to.beNil();
        });
        
        it(@"should have upload path equal to default value.", ^{
            expect(sut.path).to.equal(CRVDefaultPath);
        });
        
        it(@"should check cache.", ^{
            expect(sut.checkCache).to.beTruthy();
        });
        
        it(@"should number of retries be set to default value.", ^{
            expect(sut.numberOfRetries).to.equal(CRVDefaultNumberOfRetries);
        });
        
        it(@"should reconnection time be set to default value.", ^{
            expect(sut.reconnectionTime).to.equal(CRVDefaultReconnectionTime);
        });
        
        it(@"should conform CRVSessionManagerDelegate.", ^{
            expect(sut).conformTo(@protocol(CRVSessionManagerDelegate));
        });
        
        it(@"should respond to check cache delegate.", ^{
            expect(sut).to.respondTo(@selector(shouldSessionMangerCheckCache:));
        });
        
        it(@"should respond to number of retries delegate.", ^{
            expect(sut).to.respondTo(@selector(numberOfRetriesSessionManagerShouldPrepare:));
        });
        
        it(@"should respond to reconnection time delegate.", ^{
            expect(sut).to.respondTo(@selector(reconnectionTimeSessionManagerShouldWait:));
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
        
        beforeEach(^{
            sut = [[CRVNetworkManager alloc] init];
        });
        
        context(@"when downloading", ^{
            
            it(@"should raise an exception.", ^{
                expect(^{
                    [sut downloadAssetFromURL:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
        });
        
        context(@"when uploading", ^{
            
            it(@"should raise an exception.", ^{
                expect(^{
                    [sut uploadAsset:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
        });
        
        context(@"when deleting", ^{
            
            it(@"should raise an exception.", ^{
                expect(^{
                    [sut deleteAssetFromURL:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
        });
    });
    
    describe(@"with no provided identifier", ^{
        
        beforeEach(^{
            sut = [[CRVNetworkManager alloc] init];
            sut.serverURL = [NSURL URLWithString:@"http://www.example.com"];
        });
        
        context(@"when downloading", ^{
            
            it(@"should raise an exception.", ^{
                expect(^{
                    [sut downloadAssetWithIdentifier:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
        });
        
        context(@"when uploading", ^{
            
            it(@"should raise an exception.", ^{
                expect(^{
                    [sut uploadAsset:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
        });
        
        context(@"when deleting", ^{
            
            it(@"should raise an exception.", ^{
                expect(^{
                    [sut deleteAssetWithIdentifier:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
        });
    });
    
    describe(@"when dowloading", ^{
        
        NSString *filePath = [[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", kImageIdentifier]]] path];
        NSURL *anyURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.example.com/%@/download", kImageIdentifier]];
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
            sut = [[CRVNetworkManager alloc] init];
            sut.reconnectionTime = 0.2;
            sut.numberOfRetries = 4;
            sut.serverURL = [NSURL URLWithString:@"http://www.example.com"];
            [Expecta setAsynchronousTestTimeout:(sut.reconnectionTime * sut.numberOfRetries + 0.5)];
            anAsset = nil;
            anError = nil;
        });
        
        context(@"and checking cache", ^{
            
            beforeEach(^{
                sut.checkCache = YES;
            });
            
            it(@"should succeed without connection.", ^{
                [sut downloadAssetFromURL:anyURL progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
                    anError = error;
                    anAsset = asset;
                    expect([OHHTTPStubs retriesMade]).to.equal(0);
                }];
            
                expect(anError).will.beNil();
                expect(anAsset).will.notTo.beNil();
                expect(anAsset.dataLength).will.equal([NSData crv_defaultImageDataRepresentation].length);
            });
            
            it(@"should succeed without connection.", ^{
                [sut downloadAssetWithIdentifier:kImageIdentifier progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
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
                sut.checkCache = NO;
            });
            
            context(@"without retries", ^{
                
                beforeEach(^{
                    stub = [OHHTTPStubs crv_stubDownloadRequestWithError:CRVStubErrorNone manager:sut];
                });
                
                afterEach(^{
                    [OHHTTPStubs removeStub:stub];
                });
                
                it(@"should succeed.", ^{
                    [sut downloadAssetFromURL:anyURL progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
                        anError = error;
                        anAsset = asset;
                        expect([OHHTTPStubs retriesMade]).to.equal(0);
                    }];
                    
                    expect(anError).will.beNil();
                    expect(anAsset).will.notTo.beNil();
                    expect(anAsset.dataLength).will.equal([NSData crv_defaultImageDataRepresentation].length);
                });
                
                it(@"should succeed.", ^{
                    [sut downloadAssetWithIdentifier:kImageIdentifier progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
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
                    stub = [OHHTTPStubs crv_stubDownloadRequestWithError:CRVStubErrorRetriesLimitReached manager:sut];
                });
                
                afterEach(^{
                    [OHHTTPStubs removeStub:stub];
                });
                
                it(@"should succeed.", ^{
                    [sut downloadAssetFromURL:anyURL progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
                        anError = error;
                        anAsset = asset;
                        expect([OHHTTPStubs retriesMade]).to.equal(sut.numberOfRetries);
                    }];
                    
                    expect(anError).will.beNil();
                    expect(anAsset).will.notTo.beNil();
                    expect(anAsset.dataLength).will.equal([NSData crv_defaultImageDataRepresentation].length);
                });
                
                it(@"should succeed.", ^{
                    [sut downloadAssetWithIdentifier:kImageIdentifier progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
                        anError = error;
                        anAsset = asset;
                        expect([OHHTTPStubs retriesMade]).to.equal(sut.numberOfRetries);
                    }];
                    
                    expect(anError).will.beNil();
                    expect(anAsset).will.notTo.beNil();
                    expect(anAsset.dataLength).will.equal([NSData crv_defaultImageDataRepresentation].length);
                });
            });
            
            context(@"with retries limit exceeded", ^{
                
                beforeEach(^{
                    stub = [OHHTTPStubs crv_stubDownloadRequestWithError:CRVStubErrorRetriesLimitExceeded manager:sut];
                });
                
                afterEach(^{
                    [OHHTTPStubs removeStub:stub];
                });
                
                it(@"should fail.", ^{
                    [sut downloadAssetFromURL:anyURL progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
                        anError = error;
                        anAsset = asset;
                        expect([OHHTTPStubs retriesMade]).to.equal(sut.numberOfRetries + 1);
                    }];
                    
                    expect(anError).will.notTo.beNil();
                    expect(anAsset).will.beNil();
                });
                
                it(@"should fail.", ^{
                    [sut downloadAssetWithIdentifier:kImageIdentifier progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
                        anError = error;
                        anAsset = asset;
                        expect([OHHTTPStubs retriesMade]).to.equal(sut.numberOfRetries + 1);
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
            sut = [[CRVNetworkManager alloc] init];
            sut.reconnectionTime = 0.2;
            sut.numberOfRetries = 4;
            sut.serverURL = [NSURL URLWithString:@"http://www.example.com"];
            [Expecta setAsynchronousTestTimeout:(sut.reconnectionTime * sut.numberOfRetries + 0.5)];
            anError = nil;
        });
    
        context(@"without retries", ^{
            
            beforeEach(^{
                stub = [OHHTTPStubs crv_stubDeletionRequestWithError:CRVStubErrorNone manager:sut];
                aSuccess = NO;
            });
            
            afterEach(^{
                [OHHTTPStubs removeStub:stub];
            });
            
            it(@"should succeed.", ^{
                [sut deleteAssetWithIdentifier:@"1" completion:^(BOOL success, NSError *error) {
                    aSuccess = success;
                    anError = error;
                    expect([OHHTTPStubs retriesMade]).to.equal(0);
                }];
                
                expect(anError).will.beNil();
                expect(aSuccess).will.beTruthy();
            });
            
            it(@"should succeed.", ^{
                [sut deleteAssetFromURL:[NSURL URLWithString:@"http://www.example.com"] completion:^(BOOL success, NSError *error) {
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
                stub = [OHHTTPStubs crv_stubDeletionRequestWithError:CRVStubErrorRetriesLimitReached manager:sut];
                aSuccess = NO;
            });
            
            afterEach(^{
                [OHHTTPStubs removeStub:stub];
            });
            
            it(@"should succeed.", ^{
                [sut deleteAssetWithIdentifier:@"1" completion:^(BOOL success, NSError *error) {
                    aSuccess = success;
                    anError = error;
                    expect([OHHTTPStubs retriesMade]).to.equal(sut.numberOfRetries);
                }];
                
                expect(anError).will.beNil();
                expect(aSuccess).will.beTruthy();
            });
            
            it(@"should succeed.", ^{
                [sut deleteAssetFromURL:[NSURL URLWithString:@"http://www.example.com"] completion:^(BOOL success, NSError *error) {
                    aSuccess = success;
                    anError = error;
                    expect([OHHTTPStubs retriesMade]).to.equal(sut.numberOfRetries);
                }];
                
                expect(anError).will.beNil();
                expect(aSuccess).will.beTruthy();
            });
        });
        
        context(@"with retries limit exceeded", ^{
            
            beforeEach(^{
                stub = [OHHTTPStubs crv_stubDeletionRequestWithError:CRVStubErrorRetriesLimitExceeded manager:sut];
                aSuccess = YES;
            });
            
            afterEach(^{
                [OHHTTPStubs removeStub:stub];
            });
            
            it(@"should fail.", ^{
                [sut deleteAssetWithIdentifier:@"1" completion:^(BOOL success, NSError *error) {
                    aSuccess = success;
                    anError = error;
                    expect([OHHTTPStubs retriesMade]).to.equal(sut.numberOfRetries + 1);
                }];
                
                expect(anError).will.toNot.beNil();
                expect(aSuccess).will.beFalsy();
            });
            
            it(@"should fail.", ^{
                [sut deleteAssetFromURL:[NSURL URLWithString:@"http://www.example.com"] completion:^(BOOL success, NSError *error) {
                    aSuccess = success;
                    anError = error;
                    expect([OHHTTPStubs retriesMade]).to.equal(sut.numberOfRetries + 1);
                }];
                
                expect(anError).will.toNot.beNil();
                expect(aSuccess).will.beFalsy();
            });
        });
        
    });
    
    //OHHTTPStubs doesn't simulate data upload. Test for this stub has been omited.
});

SpecEnd
