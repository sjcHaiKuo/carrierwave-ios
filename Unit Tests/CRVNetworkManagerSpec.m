//
//  CRVNetworkManagerSpec.m
//
//  Copyright 2015 Netguru Sp. z o.o. All rights reserved.
//

#define kImageName @"testIMG.png"

SpecBegin(CRVNetworkManagerSpec)

describe(@"CRVNetworkManagerSpec", ^{
    
    __block CRVNetworkManager *manager = nil;

    describe(@"when newly created", ^{
        
        beforeEach(^{
            manager = [[CRVNetworkManager alloc] init];
        });
        
        afterEach(^{
            manager = nil;
        });

        it(@"should have no server url", ^{
            expect(manager.serverURL).to.beNil;
        });
        
        it(@"should have no upload path", ^{
            expect(manager.uploadPath).to.beNil;
        });
        
        it(@"should check cache", ^{
            expect(manager.checkCache).to.beTruthy;
        });
        
        it(@"should number of retries be set to default value", ^{
            expect(manager.numberOfRetries).to.equal(CRVDefaultNumberOfRetries);
        });
        
        it(@"should reconnection time be set to default value", ^{
            expect(manager.reconnectionTime).to.equal(CRVDefaultReconnectionTime);
        });
    });

    describe(@"when using a shared instance", ^{
        
        it(@"should return the same instance", ^{
            CRVNetworkManager *first = [CRVNetworkManager sharedManager];
            CRVNetworkManager *second = [CRVNetworkManager sharedManager];
            expect(first).to.beIdenticalTo(second);
        });
    });
    
    describe(@"with no provided url", ^{
        
        beforeEach(^{
            manager = [[CRVNetworkManager alloc] init];
        });
        
        context(@"when downloading", ^{
            
            it(@"should raise an exception", ^{
                expect(^{
                    [manager downloadAssetFromURL:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
        });
        
        context(@"when uploading", ^{
            
            it(@"should raise an exception", ^{
                expect(^{
                    [manager uploadAsset:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
        });
    });
    
    describe(@"with no provided path", ^{
        
        beforeEach(^{
            manager = [[CRVNetworkManager alloc] init];
            manager.serverURL = [NSURL URLWithString:@"http://www.example.com"];
        });
        
        context(@"when downloading", ^{
            
            it(@"should raise an exception", ^{
                expect(^{
                    [manager downloadAssetFromPath:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
        });
        
        context(@"when uploading", ^{
            
            it(@"should raise an exception", ^{
                expect(^{
                    [manager uploadAsset:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
        });
        
    });
    
    describe(@"when dowloading", ^{
        
        NSString *filePath = [[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:kImageName]] path];
        NSURL *anyURL = [NSURL URLWithString:[NSString stringWithFormat:@"httt://www.example.com/%@", kImageName]];
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
            manager = [[CRVNetworkManager alloc] init];
            manager.reconnectionTime = 0.5;
            manager.numberOfRetries = 4;
            [Expecta setAsynchronousTestTimeout:(manager.reconnectionTime * manager.numberOfRetries + 0.5)];
            anAsset = nil;
            anError = nil;
        });
        
        context(@"without retries", ^{
            
            beforeEach(^{
                stub = [OHHTTPStubs crv_stubDownloadRequestWithError:CRVStubErrorNoone  manager:manager];
            });
            
            afterEach(^{
                [OHHTTPStubs removeStub:stub];
            });
            
            it(@"should succeed", ^{
                [manager downloadAssetFromURL:anyURL progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
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
                stub = [OHHTTPStubs crv_stubDownloadRequestWithError:CRVStubErrorRetriedAtLeastOnce manager:manager];
            });
            
            afterEach(^{
                [OHHTTPStubs removeStub:stub];
            });
            
            it(@"should succeed", ^{
                [manager downloadAssetFromURL:anyURL progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
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
            
            it(@"should fail", ^{
                [manager downloadAssetFromURL:anyURL progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
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

SpecEnd

