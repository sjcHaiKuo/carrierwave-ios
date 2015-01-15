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

CRVWorkInProgress("Temporary. Need to change for quering mimetype from data.");

// Need to check how to query extension info from input stream, without affecting on stream itself.
// According to Apple documentatio: Once opened, a stream cannot be closed and reopened.

- (NSString *)mimeTypeByGuessing {
    return @"video/mp4";
}

#pragma mark - Property accessors

- (NSString *)fileName {
    if (_fileName != nil) return _fileName;
    return _fileName = [CRVAssertTypeUtils fileNameForMimeType:self.mimeType];
}

- (NSString *)mimeType {
    if (_mimeType != nil) return _mimeType;
    return _mimeType = [self mimeTypeByGuessing];
}

@end


