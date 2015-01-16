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
    uint8_t bytes[32] = {0};
    
    [stream open];
    NSInteger readBytesCount = [stream read:bytes maxLength:sizeof(bytes)];
    [stream close];
    
    // if error or empty
    if (readBytesCount <= 0) {
        return nil;
    }
    
    unsigned int signatureOffset = 4;
    
    // signatures based on http://www.garykessler.net/library/file_sigs.html
    // mov - ftypqt
    uint8_t mov[6] = { 0x66, 0x74, 0x79, 0x70, 0x71, 0x74 };
    // mp4 - ftypisom
    uint8_t mp4_isom[8] = { 0x66, 0x74, 0x79, 0x70, 0x69, 0x73, 0x6F, 0x6D};
    // mp4 - ftyp3gp5
    uint8_t mp4_3gp[8] = { 0x66, 0x74, 0x79, 0x70, 0x33, 0x67, 0x70, 0x35 };
    // m4v - ftypmp42
    uint8_t mp4_mp42[9] = { 0x66, 0x74, 0x79, 0x70, 0x6D, 0x70, 0x34, 0x32 };
    
    // try to guess by signatures
    if (!memcmp(bytes + signatureOffset, mov, sizeof(mov))) {
        return @"video/quicktime";
    } else if (!memcmp(bytes + signatureOffset, mp4_isom, sizeof(mp4_isom))
               || !memcmp(bytes + signatureOffset, mp4_3gp, sizeof(mp4_3gp))
               || !memcmp(bytes + signatureOffset, mp4_mp42, sizeof(mp4_mp42))) {
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


