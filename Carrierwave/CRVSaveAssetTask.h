//
//  CRVSaveAssetTask.h
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;

#import "CRVAssetType.h"

typedef void (^CRVSaveAssetToFileBlock)(NSString *outputFilePath, NSError *error);

typedef NS_ENUM(NSUInteger, CRVAssetFileType) {
    CRVAssetFileTemporary,
    CRVAssetFileCache,
    CRVAssetFileDocument
};

@interface CRVSaveAssetTask : NSObject

- (instancetype)initWithAsset:(id<CRVAssetType>)asset;

- (void)saveAssetAs:(CRVAssetFileType)type completion:(CRVSaveAssetToFileBlock)completion;

@end
