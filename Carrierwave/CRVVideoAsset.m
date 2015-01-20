//
//  CRVVideoAsset.m
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVVideoAsset.h"

#import "CRVAssertTypeUtils.h"
#import "CRVSaveAssetTask.h"
#import "CRVVideoFileStreamProvider.h"
#import "CRVVideoDataStreamProvider.h"

static NSString * const CRVMimeTypeMp4 = @"video/mp4";
static NSString * const CRVMimeTypeMov = @"video/quicktime";

@interface CRVVideoAsset ()

@property (strong, nonatomic, readwrite) NSString *mimeType;
@property (strong, nonatomic, readwrite) NSString *fileName;

@property (strong, nonatomic) id<CRVVideoStreamProvider> streamProvider;

@end

@implementation CRVVideoAsset

#pragma mark - Object lifecycle

- (instancetype)initWithStreamProvider:(id<CRVVideoStreamProvider>)provider mimeType:(NSString *)mimeType {
    NSParameterAssert(provider != nil);
    if (self = [super init]) {
        self.streamProvider = provider;
        self.mimeType = mimeType;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    CRVVideoDataStreamProvider *provider = [[CRVVideoDataStreamProvider alloc] initWithData:data];
    return [self initWithStreamProvider:provider mimeType:[self mimeTypeByGuessingFromData:data]];
}

- (instancetype)initWithLocalURL:(NSURL *)url {    
    CRVVideoFileStreamProvider *provider = [[CRVVideoFileStreamProvider alloc] initWithFileUrl:url];
    return [self initWithStreamProvider:provider mimeType:[self mimeTypeFormFileExtension:[url pathExtension]]];
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
    CRVSaveAssetTask *saveTask = [[CRVSaveAssetTask alloc] initWithAsset:self];
    [saveTask saveAssetAs:CRVAssetFileTemporary completion:^(NSString *outputFilePath, NSError *error) {
        if (!error) {
            
            // Update file provider to cached file
            weakSelf.streamProvider = [[CRVVideoFileStreamProvider alloc] initWithFilePath:outputFilePath];
        
            AVPlayerItem *videoItem = [AVPlayerItem playerItemWithURL:self.videoUrl];
            completion(videoItem, nil);
            
        } else {
            completion(nil, error);
        }
    }];
}

#pragma mark - Property accessors

- (NSInputStream *)dataStream {
    return self.streamProvider.inputStream;
}

- (NSNumber *)dataLength {
    return self.streamProvider.inputStreamLength;
}

- (NSString *)fileName {
    if (_fileName != nil) return _fileName;
    return _fileName = [CRVAssertTypeUtils fileNameForMimeType:self.mimeType];
}

@end


