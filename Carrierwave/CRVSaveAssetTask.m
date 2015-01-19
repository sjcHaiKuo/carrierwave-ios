//
//  CRVSaveAssetTask.m
//  Carrierwave
//
//  Created by Wojciech Trzasko on 16.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSaveAssetTask.h"

#import "NSError+Carrierwave.h"

@interface CRVSaveAssetTask () <NSStreamDelegate>

@property (strong, nonatomic) id<CRVAssetType> asset;
@property (strong, nonatomic) NSOutputStream *outputStream;
@property (assign, nonatomic) CRVAssetFileType fileType;

@property (copy) CRVSaveAssetToFileBlock saveTempCompletion;

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
    self.saveTempCompletion = completion;
    self.fileType = type;

    NSString *filePath = [self filePathForName:self.asset.fileName type:self.fileType];
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [self.outputStream open];
    
    self.asset.dataStream.delegate = self;
    [self.asset.dataStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                     forMode:NSDefaultRunLoopMode];
    [self.asset.dataStream open];
}

#pragma mark - NSInputStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
            [self streamHasBytesAvailable:aStream];
            break;
            
        case NSStreamEventEndEncountered:
            [self streamEndEncountered:aStream];
            break;
            
        case NSStreamEventErrorOccurred:
            [self streamErrorOccured:aStream];
            break;
            
        default:
            break;
    }
}

#pragma mark - Stream actions

- (void)streamHasBytesAvailable:(NSStream *)stream {
    NSInputStream *inputStream = (NSInputStream *)stream;
    
    uint8_t buffer[1024];
    NSInteger readLength = [inputStream read:buffer maxLength:sizeof(buffer)];
    
    CRVTemporary("[WIP] A lot of potential dangers. Needs complex testing.");
    if (readLength > 0) {
        NSInteger writeLength = [self.outputStream write:buffer maxLength:sizeof(buffer)];
        if (writeLength < 0) {
            [self streamErrorOccured:self.outputStream];
        }
    } else if (readLength < 0) {
        [self streamErrorOccured:stream];
    }
}

- (void)streamEndEncountered:(NSStream *)stream {
    [self freeAssetDataStream];
    [self freeOutputStream];
    
    if (self.saveTempCompletion) {
        NSString *filePath = [self filePathForName:self.asset.fileName type:self.fileType];
        self.saveTempCompletion(filePath, nil);
    }
}

- (void)streamErrorOccured:(NSStream *)stream {
    NSError *error = [stream streamError];
    
    [self freeAssetDataStream];
    [self freeOutputStream];
    
    if (self.saveTempCompletion) {
        self.saveTempCompletion(nil, error);
    }
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
