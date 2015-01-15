//
//  CRVNetworkManagerSpec.m
//
//  Copyright 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "OHHTTPStubs+CRVTests.h"
#import "NSData+CRVComposition.h"

#define kImageName @"testIMG.png"
#define kSwizzledCRVDefaultReconnectionTime 0.5

SpecBegin(CRVNetworkManagerSpec)

describe(@"CRVNetworkManagerSpec", ^{
    
    __block CRVNetworkManager *manager = nil;
    
    beforeAll(^{
        [Expecta setAsynchronousTestTimeout:(kSwizzledCRVDefaultReconnectionTime * CRVDefaultNumberOfRetries + 0.5)];
    });
    
    beforeEach(^{
        manager = [CRVNetworkManager sharedManager];
    });
    
    context(@"when newly created", ^{

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

    context(@"when using a shared instance", ^{
        
        it(@"should return the same instance", ^{
            CRVNetworkManager *first = [CRVNetworkManager sharedManager];
            CRVNetworkManager *second = [CRVNetworkManager sharedManager];
            expect(first).to.beIdenticalTo(second);
        });
    });
    
    describe(@"when dowloading", ^{
        
        context(@"should raise an exception", ^{
            
            beforeEach(^{
                manager.serverURL = nil;
            });
            
            it(@"with no provided url", ^{
                expect(^{
                    [manager downloadAssetFromPath:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
            
            it(@"with no provided url", ^{
                expect(^{
                    [manager downloadAssetFromURL:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
            
            it(@"with no provided path", ^{
                expect(^{
                    manager.serverURL = [NSURL URLWithString:@"http://www.example.com"];
                    [manager downloadAssetFromPath:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
        });
        
        context(@"using correct data", ^{
            
            __block id<OHHTTPStubsDescriptor> stub = nil;
            __block CRVImageAsset *anAsset = nil;
            __block NSError *anError = nil;
            
            NSString *filePath = [[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:kImageName]] path];
            
            beforeAll(^{
                stub = [OHHTTPStubs crv_stubDownloadRequestForIdentifier:@"STUB_1"];
                [[NSData crv_defaultImageRepresentedByData] writeToFile:filePath atomically:YES];
                manager.reconnectionTime = kSwizzledCRVDefaultReconnectionTime;
            });
            
            afterAll(^{
                [OHHTTPStubs removeStub:stub];
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
                manager.reconnectionTime = CRVDefaultReconnectionTime;
            });
            
            beforeEach(^{
                anAsset = nil;
                anError = nil;
            });
            
            it(@"should download asset with success", ^{
                
                NSURL *anyURL = [NSURL URLWithString:[NSString stringWithFormat:@"httt://www.example.com/%@", kImageName]];
                [manager downloadAssetFromURL:anyURL progress:nil completion:^(CRVImageAsset *asset, NSError *error) {
                    anError = error;
                    anAsset = asset;
                }];
                
                expect(anError).will.beNil();
                expect(anAsset).will.notTo.beNil();
                expect(anAsset.dataLength).will.equal([NSData crv_defaultImageRepresentedByData].length);
            });
        });
    });
    
    describe(@"when uploading", ^{
        
        context(@"should raise an exception", ^{
            beforeEach(^{
                manager.serverURL = nil;
            });
            
            it(@"with no provided url", ^{
                expect(^{
                    [manager uploadAsset:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
            
            it(@"with no provided url", ^{
                expect(^{
                    [manager uploadAsset:nil toURL:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
            
            
            it(@"with no provided upload path", ^{
                expect(^{
                    manager.serverURL = [NSURL URLWithString:@"http://www.example.com"];
                    [manager uploadAsset:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
        });
    });
    
});

SpecEnd

