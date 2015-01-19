//
//  CRVSaveAssetTask.m
//  Carrierwave
//
//  Created by Wojciech Trzasko on 16.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSaveAssetTask.h"

@interface CRVSaveAssetTask () <NSStreamDelegate>

@property (strong, nonatomic) id<CRVAssetType> asset;
@property (strong, nonatomic) NSOutputStream *outputStream;

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

- (void)saveInTemporaryWithCompletion:(CRVSaveAssetToFileBlock)completion {
    self.saveTempCompletion = completion;

    self.outputStream = [NSOutputStream outputStreamToFileAtPath:[self outputFilePath] append:NO];
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
    NSInteger length = [inputStream read:buffer maxLength:sizeof(buffer)];
    
    CRVTemporary("[WIP] Should we end reading if length < 0? Need small research!");
    CRVTemporary("[WIP] What if error occurs when reading from stream inited by NSData?");
    // According to Apple Docs stream after close can't be reopen. What if error occurs while
    // reading from stream? In case of file => no problem, recreate stream with file.
    // What in case of reading from NSData? Are data lost? Should we retain NSData for reading?
    // Need a better error handling in here.
    if (length > 0) {
        [self.outputStream write:buffer maxLength:sizeof(buffer)];
    }
}

- (void)streamEndEncountered:(NSStream *)stream {
    [self freeAssetDataStream];
    [self freeOutputStream];
    
    if (self.saveTempCompletion) {
        self.saveTempCompletion([self outputFilePath], nil);
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

#pragma mark - Helpers

- (void)freeAssetDataStream {
    [self.asset.dataStream close];
    [self.asset.dataStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)freeOutputStream {
    [self.outputStream close];
    self.outputStream = nil;
}

- (NSString *)outputFilePath {
    return [NSTemporaryDirectory() stringByAppendingString:self.asset.fileName];
}

@end
