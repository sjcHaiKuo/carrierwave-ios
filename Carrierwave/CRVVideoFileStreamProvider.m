//
//  CRVVideoFileStreamProvider.m
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVVideoFileStreamProvider.h"

@interface CRVVideoFileStreamProvider ()

@property (strong, nonatomic, readwrite) NSURL *fileURL;
@property (strong, nonatomic, readwrite) NSNumber *fileLength;

@end

@implementation CRVVideoFileStreamProvider

- (instancetype)initWithFileUrl:(NSURL *)url {
    NSParameterAssert([url isFileURL]);
    NSParameterAssert([url checkResourceIsReachableAndReturnError:nil]);

    if (self = [super init]) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error:nil];
        NSAssert(fileAttributes, @"Can't find attributes for file at given path.");
        
        self.fileURL = url;
        self.fileLength = [fileAttributes objectForKey:NSFileSize];
    }
    return self;
}

- (instancetype)initWithFilePath:(NSString *)filePath {
    return [self initWithFileUrl:[NSURL fileURLWithPath:filePath]];
}

- (NSInputStream *)inputStream {
    return [NSInputStream inputStreamWithURL:self.fileURL];
}

- (NSNumber *)inputStreamLength {
    return [self.fileLength copy];
}

@end
