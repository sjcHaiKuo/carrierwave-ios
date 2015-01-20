//
//  CRVVideoAsset.h
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;
@import AVFoundation;

#import "CRVAssetType.h"
#import "CRVVideoAssetTypedefs.h"

/**
 * The CRVImageAsset class is used to represent video which can be uploaded to
 * the carrierwave-powered server backend.
 */
@interface CRVVideoAsset : NSObject <CRVAssetType>

@property (strong, nonatomic, readonly) NSURL *videoUrl;

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

/**
 * Loads video to AVPlayerItem object.
 *
 * @param completion The completion block executed when load operation finishes with error or success. If failed returns an error. Otherwise nil. If succeed returns an configured AVPlayerItem object.
 */
- (void)loadVideoWithCompletion:(CRVVideoLoadCompletionBlock)completion;

@end
