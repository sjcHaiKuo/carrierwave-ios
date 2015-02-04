//
//  CRVSessionManagerSpec.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 19.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVSessionManagerSpec)

describe(@"CRVSessionManagerSpec", ^{
    
    __block CRVSessionManager *manager = nil;
    
    beforeEach(^{
        manager = [[CRVSessionManager alloc] init];
    });
    
    afterEach(^{
        manager = nil;
    });
    
    describe(@"downloading data", ^{
        
        __block NSString *url = nil;
        
        beforeEach(^{
            url = @"www.example.com";
        });
        
        context(@"with invalid inputs, should raise an exception", ^{
            
            it(@"without url provided.", ^{
                expect(^{
                    [manager downloadAssetFromURL:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
        });
        
        context(@"with valid inputs", ^{
            
            __block NSString *identifier;
            
            beforeEach(^{
                identifier = [manager downloadAssetFromURL:url progress:nil completion:nil];
            });
            
            it(@"identifier should exist.", ^{
                expect(identifier).toNot.beNil();
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
                    [manager uploadAssetRepresentedByDataStream:nil withLength:length name:name mimeType:mimeType URLString:URLString progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
            
            it(@"without length provided.", ^{
                expect(^{
                    [manager uploadAssetRepresentedByDataStream:stream withLength:nil name:name mimeType:mimeType URLString:URLString progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
            
            it(@"without name provided.", ^{
                expect(^{
                    [manager uploadAssetRepresentedByDataStream:stream withLength:length name:nil mimeType:mimeType URLString:URLString progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
            
            it(@"without mimeType provided.", ^{
                expect(^{
                    [manager uploadAssetRepresentedByDataStream:stream withLength:length name:name mimeType:nil URLString:URLString progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
            
            it(@"without url provided.", ^{
                expect(^{
                    [manager uploadAssetRepresentedByDataStream:stream withLength:length name:name mimeType:mimeType URLString:nil progress:nil completion:nil];
                }).to.raise(NSInternalInconsistencyException);
            });
        });
        
        context(@"with valid inputs", ^{
            
            __block NSString *identifier;

            beforeEach(^{
                identifier = [manager uploadAssetRepresentedByDataStream:stream withLength:length name:name mimeType:mimeType URLString:URLString progress:nil completion:nil];
            });
            
            it(@"identifier should exist.", ^{
                expect(identifier).toNot.beNil();
            });
        });
    });
    
});

SpecEnd
