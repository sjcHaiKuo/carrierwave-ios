//
//  CRVVideoAsset.m
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVVideoAsset.h"

#import "CRVAssertTypeUtils.h"
#import "CRVSaveAssetTask.h"

static NSString * const CRVMimeTypeMp4 = @"video/mp4";
static NSString * const CRVMimeTypeMov = @"video/quicktime";

@interface CRVVideoAsset ()

@property (strong, nonatomic, readwrite) NSString *mimeType;
@property (strong, nonatomic, readwrite) NSString *fileName;
@property (strong, nonatomic, readwrite) NSInputStream *dataStream;
@property (strong, nonatomic, readwrite) NSNumber *dataLength;

@property (strong, nonatomic, readwrite) NSURL *videoUrl;

@end

@implementation CRVVideoAsset

#pragma mark - Object lifecycle

- (instancetype)initWithDataStream:(NSInputStream *)dataStream length:(NSNumber *)length mimeType:(NSString *)mimeType {
    NSParameterAssert(dataStream != nil && length != nil);
    self = [super init];
    if (self == nil) return nil;
    self.dataStream = dataStream;
    self.dataLength = length;
    self.mimeType = mimeType;
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    return [self initWithDataStream:[[NSInputStream alloc] initWithData:data]
                             length:@(data.length)
                           mimeType:[self mimeTypeByGuessingFromData:data]];
}

- (instancetype)initWithLocalURL:(NSURL *)url {
    NSParameterAssert([url isFileURL] && [url checkResourceIsReachableAndReturnError:nil]);
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error:nil];
    NSAssert(fileAttributes, @"Can't find attributes for file at given path.");
    
    self = [self initWithDataStream:[[NSInputStream alloc] initWithURL:url]
                             length:[fileAttributes objectForKey:NSFileSize]
                           mimeType:[self mimeTypeFormFileExtension:[url pathExtension]]];
    if (self) {
        self.videoUrl = url;
    }
    
    return self;
}

#pragma mark - Mimetypes helpers

- (NSString *)mimeTypeFormFileExtension:(NSString *)fileExtension {
    NSDictionary *mimetypeMap = @{ @"mp4" : CRVMimeTypeMp4,
                                   @"mov" : CRVMimeTypeMov };
    return mimetypeMap[fileExtension];
}

- (NSString *)mimeTypeByGuessingFromData:(NSData *)data {
    
    // read bytes
    char bytes[32] = {0};
    [data getBytes:&bytes length:sizeof(bytes)];
    
    unsigned int signatureOffset = 4;
    
    // signatures based on http://www.garykessler.net/library/file_sigs.html
    // mov - ftypqt
    uint8_t mov[6] = { 0x66, 0x74, 0x79, 0x70, 0x71, 0x74 };
    // mp4 - ftypisom
    uint8_t mp4_isom[8] = { 0x66, 0x74, 0x79, 0x70, 0x69, 0x73, 0x6F, 0x6D };
    // mp4 - ftyp3gp5
    uint8_t mp4_3gp[8] = { 0x66, 0x74, 0x79, 0x70, 0x33, 0x67, 0x70, 0x35 };
    // m4v - ftypmp42
    uint8_t mp4_mp42[9] = { 0x66, 0x74, 0x79, 0x70, 0x6D, 0x70, 0x34, 0x32 };
    
    // try to guess by signatures
    if (!memcmp(bytes + signatureOffset, mov, sizeof(mov))) {
        return CRVMimeTypeMov;
    } else if (!memcmp(bytes + signatureOffset, mp4_isom, sizeof(mp4_isom))
               || !memcmp(bytes + signatureOffset, mp4_3gp, sizeof(mp4_3gp))
               || !memcmp(bytes + signatureOffset, mp4_mp42, sizeof(mp4_mp42))) {
        return CRVMimeTypeMp4;
    }
    
    // default
    return nil;
}

#pragma makr - Load video

- (void)loadVideoWithCompletion:(CRVVideoLoadCompletionBlock)completion {
    if (!completion) {
        return;
    }
    
    if (self.videoUrl) {
        AVPlayerItem *videoItem = [AVPlayerItem playerItemWithURL:self.videoUrl];
        completion(videoItem, nil);
    }
    
    __weak typeof(self) weakSelf = self;
    [[[CRVSaveAssetTask alloc] initWithAsset:self] saveInTemporaryWithCompletion:^(NSString *outputFilePath, NSError *error) {
        weakSelf.videoUrl = [NSURL URLWithString:outputFilePath];
        weakSelf.dataStream = [[NSInputStream alloc] initWithFileAtPath:outputFilePath];
    }];
}

#pragma mark - Property accessors

- (NSString *)fileName {
    if (_fileName != nil) return _fileName;
    return _fileName = [CRVAssertTypeUtils fileNameForMimeType:self.mimeType];
}

@end


