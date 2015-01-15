//
//  CRVVideoAsset.h
//  Carrierwave
//
//  Created by Wojciech Trzasko on 15.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;

#import "CRVAssetType.h"

/**
 * The CRVImageAsset class is used to represent video which can be uploaded to
 * the carrierwave-powered server backend.
 */
@interface CRVVideoAsset : NSObject <CRVAssetType>

/**
 * Creates the video asset using the data stream of an image.
 *
 * @param dataStream The data stream of the video to be represented by the asset.
 * @param length     The length of data stream.
 *
 * @return An initialized receiver.
 */
- (instancetype)initWithDataStream:(NSInputStream *)dataStream length:(NSNumber *)length NS_DESIGNATED_INITIALIZER;

/**
 * Creates the video asset using the data of an video.
 *
 * @param image The data of the video to be represented by the asset.
 *
 * @return An initialized receiver.
 */
- (instancetype)initWithData:(NSData *)data;

/**
 * Creates the video asset by loading a local video under the specified URL.
 *
 * @param url The URL of a local video file to be represented by the asset.
 *
 * @return An initialized receiver.
 */
- (instancetype)initWithLocalURL:(NSURL *)url;

@end
