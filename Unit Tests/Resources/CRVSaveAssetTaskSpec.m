//
//  CRVSaveAssetTaskSpec.m
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVSaveAssetTaskSpec)

describe(@"CRVSaveAssetTaskSpec", ^{
    
    describe(@"using valid asset", ^{
        
        __block CRVVideoAsset *asset;
        __block NSData *inputData;
        
        beforeAll(^{
            char testBuffer[12] = {0x00, 0x00, 0x00, 0x00, 0x66, 0x74, 0x79, 0x70, 0x69, 0x73, 0x6F, 0x6D};
            inputData = [NSData dataWithBytes:&testBuffer length:sizeof(testBuffer)];
            asset = [[CRVVideoAsset alloc] initWithData:inputData];
        });
        
        context(@"when output buffer has free space", ^{
            
            __block NSOutputStream *outputStream;
            __block CRVTestSaveAssetTask *saveTask;
            
            beforeEach(^{
                outputStream = [NSOutputStream outputStreamToMemory];
                saveTask = [[CRVTestSaveAssetTask alloc] initWithAsset:asset];
                saveTask.outputStream = outputStream;
            });
            
            it(@"should save asset data to output", ^{
                __block NSData *savedData = nil;
                waitUntil(^(DoneCallback done) {
                    [saveTask saveAssetAs:CRVAssetFileTemporary completion:^(NSString *outputFilePath, NSError *error) {
                        savedData = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
                        done();
                    }];
                });
                
                expect(savedData).to.equal(inputData);
            });
            
            it(@"should return path to cache file", ^{
                __block NSString *savedFilePath = nil;
                waitUntil(^(DoneCallback done) {
                    [saveTask saveAssetAs:CRVAssetFileCache completion:^(NSString *outputFilePath, NSError *error) {
                        savedFilePath = outputFilePath;
                        done();
                    }];
                });
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *cachesDirectoryPath = [paths firstObject];
                NSString *validOutputPath = [cachesDirectoryPath stringByAppendingString:asset.fileName];
                
                expect(savedFilePath).to.equal(validOutputPath);
            });
            
            it(@"should return path to library file", ^{
                __block NSString *savedFilePath = nil;
                waitUntil(^(DoneCallback done) {
                    [saveTask saveAssetAs:CRVAssetFileDocument completion:^(NSString *outputFilePath, NSError *error) {
                        savedFilePath = outputFilePath;
                        done();
                    }];
                });
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                NSString *libraryDirectoryPath = [paths firstObject];
                NSString *validOutputPath = [libraryDirectoryPath stringByAppendingString:asset.fileName];
                
                expect(savedFilePath).to.equal(validOutputPath);
            });
            
            it(@"should return path to temporary file", ^{
                __block NSString *savedFilePath = nil;
                waitUntil(^(DoneCallback done) {
                    [saveTask saveAssetAs:CRVAssetFileTemporary completion:^(NSString *outputFilePath, NSError *error) {
                        savedFilePath = outputFilePath;
                        done();
                    }];
                });
                
                NSString *validOutputPath = [NSTemporaryDirectory() stringByAppendingString:asset.fileName];
                expect(savedFilePath).to.equal(validOutputPath);
            });
            
        });
        
        context(@"when output buffer has no free space", ^{
            
            __block NSOutputStream *outputStream;
            __block CRVTestSaveAssetTask *saveTask;
            
            beforeEach(^{
                uint8_t testBuffer[1] = { 0x00 };
                outputStream = [NSOutputStream outputStreamToBuffer:testBuffer capacity:sizeof(testBuffer)];
                saveTask = [[CRVTestSaveAssetTask alloc] initWithAsset:asset];
                saveTask.outputStream = outputStream;
            });
            
            it(@"should return error", ^{
                __block NSError *savingError = nil;
                waitUntil(^(DoneCallback done) {
                    [saveTask saveAssetAs:CRVAssetFileTemporary completion:^(NSString *outputFilePath, NSError *error) {
                        savingError = error;
                        done();
                    }];
                });
                expect(savingError).toNot.beNil();
            });
        });
        
    });
    
});

SpecEnd
