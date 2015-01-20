//
//  CRVSaveAssetTask.m
//  Carrierwave
//
//  Created by Wojciech Trzasko on 16.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSaveAssetTask.h"

static NSUInteger const CRVBufferSize = 4096;

@interface CRVSaveAssetTask () <NSStreamDelegate>

@property (strong, nonatomic) id<CRVAssetType> asset;
@property (strong, nonatomic) NSOutputStream *outputStream;
@property (assign, nonatomic) CRVAssetFileType fileType;

@end

@implementation CRVSaveAssetTask

#pragma mark - Object lifecycle

- (instancetype)initWithAsset:(id<CRVAssetType>)asset {
    self = [super init];
    if (self) {
        self.asset = asset;
    }
    return self;
}

#pragma mark - Save operations

- (void)saveAssetAs:(CRVAssetFileType)type completion:(CRVSaveAssetToFileBlock)completion; {
    
    // Inspirated by AFNetworking AFURLRequestSerialization
    // https://github.com/AFNetworking/AFNetworking/blob/master/AFNetworking/AFURLRequestSerialization.m#L379
    
    if (!completion) {
        return;
    }
    
    self.fileType = type;
    
    NSString *filePath = [self filePathForName:self.asset.fileName type:self.fileType];
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    NSInputStream *inputStream = self.asset.dataStream;
    
    __block NSError *error = nil;

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
        NSString *runLoopMode = NSDefaultRunLoopMode;
        
        [inputStream scheduleInRunLoop:currentRunLoop forMode:runLoopMode];
        [inputStream open];

        [outputStream scheduleInRunLoop:currentRunLoop forMode:runLoopMode];
        [outputStream open];
        
        while ([inputStream hasBytesAvailable] && [outputStream hasSpaceAvailable]) {
            
            uint8_t buffer[CRVBufferSize];
            
            NSInteger readLength = [inputStream read:buffer maxLength:sizeof(buffer)];
            if (readLength < 0) {
                error = inputStream.streamError;
                break;
            }
            
            NSInteger writeLength = [self.outputStream write:buffer maxLength:sizeof(buffer)];
            if (writeLength < 0) {
                error = outputStream.streamError;
                break;
            }
            
            if (readLength == 0 && writeLength == 0) break;
        }
        
        [inputStream close];
        [inputStream removeFromRunLoop:currentRunLoop forMode:runLoopMode];
        
        [outputStream close];
        [outputStream removeFromRunLoop:currentRunLoop forMode:runLoopMode];
        
        if (completion) {
            if (error) {
                completion(nil, error);
            } else {
                NSString *filePath = [weakSelf filePathForName:weakSelf.asset.fileName
                                                          type:weakSelf.fileType];
                completion(filePath, nil);
            }
        }
    });
}

#pragma mark - Output paths

- (NSString *)filePathForName:(NSString *)fileName type:(CRVAssetFileType)type {
    switch (type) {
        case CRVAssetFileCache:
            return [self filePathInCacheDirectoryForName:fileName];
            
        case CRVAssetFileDocument:
            return [self filePathInLibraryDirectoryForName:fileName];
            
        case CRVAssetFileTemporary:
            return [self filePathInTempDirectoryForName:fileName];
    }
}

- (NSString *)filePathInTempDirectoryForName:(NSString *)name {
    return [NSTemporaryDirectory() stringByAppendingString:name];
}

- (NSString *)filePathInCacheDirectoryForName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectoryPath = paths[0];
    return [cachesDirectoryPath stringByAppendingString:name];
}

- (NSString *)filePathInLibraryDirectoryForName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectoryPath = paths[0];
    return [libraryDirectoryPath stringByAppendingString:name];
}

#pragma mark - Helpers

- (void)freeAssetDataStream {
    [self.asset.dataStream close];
    [self.asset.dataStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)freeOutputStream {
    [self.outputStream close];
    self.outputStream = nil;
}

@end
