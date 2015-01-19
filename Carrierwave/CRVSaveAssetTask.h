//
//  CRVSaveAssetTask.h
//  Carrierwave
//
//  Created by Wojciech Trzasko on 16.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;

#import "CRVAssetType.h"

typedef void (^CRVSaveAssetToFileBlock)(NSString *outputFilePath, NSError *error);

@interface CRVSaveAssetTask : NSObject

- (instancetype)initWithAsset:(id<CRVAssetType>)asset;

CRVTemporary("[WIP] Make one method to rule theam all.");
// One of next steps.
// Method should get type enum that will point where to save file.
// Example: [saveAssetAs:DVSTemporaryFile completion:some_block];
//          [saveAssetAs:DVSCacheFile completion:some_block];
- (void)saveInTemporaryWithCompletion:(CRVSaveAssetToFileBlock)completion;

@end
