//
//  CRVTestSaveAssetTask.h
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;

@interface CRVTestSaveAssetTask : CRVSaveAssetTask

/**
 *  Output stream used to save asset.
 *
 *  This property is read-write in the test class.
 */
@property (strong, nonatomic, readwrite) NSOutputStream *outputStream;

@end
