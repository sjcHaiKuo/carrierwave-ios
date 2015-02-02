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

/*
 * CRVSaveAssetTask is class that refers to the lifetime of processing a save request.
 */
@interface CRVSaveAssetTask : NSObject

/**
 *  Output stream used to save asset.
 */
@property (strong, nonatomic, readonly) NSOutputStream *outputStream;

/**
 * Creates the task object using asset.
 *
 * @param asset Asset representing data to save.
 *
 * @return An initialized receiver.
 */
- (instancetype)initWithAsset:(id<CRVAssetType>)asset;

/**
 * Saves data provided by asset data stream to file.
 *
 * @param type The action specifying where file should be saved.
 * @param completion The completion block executed when saving operation finishes.
 *
 * @return An initialized receiver.
 */
- (void)saveAssetAs:(CRVAssetFileType)type completion:(CRVSaveAssetToFileBlock)completion;

@end
