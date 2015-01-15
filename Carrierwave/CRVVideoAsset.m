//
//  CRVVideoAsset.m
//  Carrierwave
//
//  Created by Wojciech Trzasko on 15.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVVideoAsset.h"

#import "CRVAssertTypeUtils.h"

@interface CRVVideoAsset ()

@property (strong, nonatomic, readwrite) NSString *mimeType;
@property (strong, nonatomic, readwrite) NSString *fileName;
@property (strong, nonatomic, readwrite) NSInputStream *dataStream;
@property (strong, nonatomic, readwrite) NSNumber *dataLength;

@end

@implementation CRVVideoAsset

#pragma mark - Object lifecycle

- (instancetype)initWithDataStream:(NSInputStream *)dataStream length:(NSNumber *)length {
    NSParameterAssert(dataStream != nil && length != nil);
    self = [super init];
    if (self == nil) return nil;
    self.dataStream = dataStream;
    self.dataLength = length;
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    return [self initWithDataStream:[[NSInputStream alloc] initWithData:data]
                             length:@(data.length)];
}

- (instancetype)initWithLocalURL:(NSURL *)url {
    NSParameterAssert([url isFileURL] && [url checkResourceIsReachableAndReturnError:nil]);
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error:nil];
    NSParameterAssert(fileAttributes);
    
    return [self initWithDataStream:[[NSInputStream alloc] initWithURL:url]
                             length:[fileAttributes objectForKey:NSFileSize]];
}

#pragma mark - Mimetypes helpers

CRVWorkInProgress("Temporary. Still work in progress. Needs tests.");

// Need to check how to query extension info from input stream, without affecting stream itself.
// According to Apple documentatio: Once opened, a stream cannot be closed and reopened.

- (NSString *)mimeTypeByGuessingFromStream:(NSInputStream *)stream {
    
    // read bytes
    uint8_t bytes[16] = {0};
    
    [stream open];
    NSInteger readBytesCount = [stream read:bytes maxLength:sizeof(bytes)];
    [stream close];
    
    // if error or empty
    if (readBytesCount <= 0) {
        return nil;
    }
    
    // initialize signatures
    const char mov1[8] = { 0x00, 0x00, 0x00, 0x14, 0x66, 0x74, 0x79, 0x70 };
    const char mov2[8] = { 0x00, 0x00, 0x00, 0x00, 0x6D, 0x6F, 0x6F, 0x76 };
    const char mov3[8] = { 0x00, 0x00, 0x00, 0x00, 0x71, 0x74, 0x20, 0x20 };
    const char mov4[8] = { 0x00, 0x00, 0x00, 0x00, 0x66, 0x72, 0x65, 0x65 };
    const char mov5[8] = { 0x00, 0x00, 0x00, 0x00, 0x6D, 0x64, 0x61, 0x74 };
    const char mov6[8] = { 0x00, 0x00, 0x00, 0x00, 0x77, 0x69, 0x64, 0x65 };
    const char mov7[8] = { 0x00, 0x00, 0x00, 0x00, 0x70, 0x6E, 0x6F, 0x74 };
    const char mov8[8] = { 0x00, 0x00, 0x00, 0x00, 0x73, 0x6B, 0x69, 0x70 };
    
    // full mp4 file signature:
    // 00 00 00 nn 66 74 79 70 33 67 70 35
    unsigned int mp4Offset = 4;
    const char mp4[9] = { 0x66, 0x74, 0x79, 0x70, 0x33, 0x67, 0x70, 0x35 };
    
    // try to guess by signatures
    if (!memcmp(bytes, mov1, 8)
        || !memcmp(bytes, mov2, 8)
        || !memcmp(bytes, mov3, 8)
        || !memcmp(bytes, mov4, 8)
        || !memcmp(bytes, mov5, 8)
        || !memcmp(bytes, mov6, 8)
        || !memcmp(bytes, mov7, 8)
        || !memcmp(bytes, mov8, 8)) {
        return @"video/quicktime";
    } else if (!memcmp(bytes + mp4Offset, mp4, 13)) {
        return @"video/mp4";
    }
    
    // default
    return nil;
}

#pragma mark - Property accessors

- (NSString *)fileName {
    if (_fileName != nil) return _fileName;
    return _fileName = [CRVAssertTypeUtils fileNameForMimeType:self.mimeType];
}

- (NSString *)mimeType {
    if (_mimeType != nil) return _mimeType;
    return _mimeType = [self mimeTypeByGuessingFromStream:self.dataStream];
}

@end


