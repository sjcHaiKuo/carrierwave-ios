//
//  CRVNetworkManagerSpec.m
//
//  Copyright 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVNetworkManagerSpec)

describe(@"CRVNetworkManagerSpec", ^{
    
    __block CRVNetworkManager *manager = nil;
    
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

