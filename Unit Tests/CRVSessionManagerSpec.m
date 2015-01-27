//
//  CRVSessionManagerSpec.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 19.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

static NSUInteger CRVSessionManagerTestWrapperIdentifier; //to follow static wrapper identifier in SUT

SpecBegin(CRVSessionManagerSpec)

describe(@"CRVSessionManagerSpec", ^{
    
    __block CRVSessionManager *sut = nil;
    
    describe(@"downloading data", ^{
        
        __block NSString *url = nil;
        
        beforeEach(^{
            sut = [[CRVSessionManager alloc] init];
            url = @"www.example.com";
        });
        
        context(@"with invalid inputs, should raise an exception", ^{
            
            it(@"without url provided.", ^{
                expect(^{
                    [sut downloadAssetFromURL:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
            
        });
        
        context(@"with valid inputs", ^{
            
            __block NSString *identifier;
            __block NSInteger initialIdentifier;
            
            beforeAll(^{
                CRVSessionManagerTestWrapperIdentifier = 0;
                initialIdentifier = [[sut downloadAssetFromURL:url progress:nil completion:nil] integerValue];
            });
            
            beforeEach(^{
                CRVSessionManagerTestWrapperIdentifier++;
                identifier = [sut downloadAssetFromURL:url progress:nil completion:nil];
            });
            
            it(@"identifier should be incremented.", ^{
                expect([identifier integerValue] - initialIdentifier).to.equal(CRVSessionManagerTestWrapperIdentifier);
            });
        });
    });
    
    describe(@"uploading data", ^{
    
        __block NSInputStream *stream = nil;
        __block NSNumber *length = nil;
        __block NSString *name = nil;
        __block NSString *mimeType = nil;
        __block NSString *URLString = nil;
        
        beforeEach(^{
            sut = [[CRVSessionManager alloc] init];
            NSData *data = [NSData crv_defaultImageDataRepresentation];
            stream = [[NSInputStream alloc] initWithData:data];
            length = @(data.length);
            mimeType = @"image/png";
            URLString = @"www.example.com";
            name = @"an asset";
        });
        
        context(@"with invalid inputs, should raise an exception", ^{
            
            it(@"without stream provided.", ^{
                expect(^{
                    [sut uploadAssetRepresentedByDataStream:nil withLength:length name:name mimeType:mimeType URLString:URLString progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
            
            it(@"without length provided.", ^{
                expect(^{
                    [sut uploadAssetRepresentedByDataStream:stream withLength:nil name:name mimeType:mimeType URLString:URLString progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
            
            it(@"without name provided.", ^{
                expect(^{
                    [sut uploadAssetRepresentedByDataStream:stream withLength:length name:nil mimeType:mimeType URLString:URLString progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
            
            it(@"without mimeType provided.", ^{
                expect(^{
                    [sut uploadAssetRepresentedByDataStream:stream withLength:length name:name mimeType:nil URLString:URLString progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
            
            it(@"without url provided.", ^{
                expect(^{
                    [sut uploadAssetRepresentedByDataStream:stream withLength:length name:name mimeType:mimeType URLString:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
        });
        
        context(@"with valid inputs", ^{
            
            __block NSString *identifier;
            __block NSInteger initialIdentifier;
            
            beforeAll(^{
                CRVSessionManagerTestWrapperIdentifier = 0;
                initialIdentifier = [[sut uploadAssetRepresentedByDataStream:stream withLength:length name:name mimeType:mimeType URLString:URLString progress:nil completion:nil] integerValue];
            });

            beforeEach(^{
                CRVSessionManagerTestWrapperIdentifier++;
                identifier = [sut uploadAssetRepresentedByDataStream:stream withLength:length name:name mimeType:mimeType URLString:URLString progress:nil completion:nil];
            });
            
            it(@"identifier should be incremented.", ^{
                expect([identifier integerValue] - initialIdentifier).to.equal(CRVSessionManagerTestWrapperIdentifier);
            });
        });
        
    });
    
});

SpecEnd
