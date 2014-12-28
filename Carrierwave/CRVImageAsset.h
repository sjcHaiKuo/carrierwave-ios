//
//  CRVImageAsset.h
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;
@import MobileCoreServices;
@import UIKit;

#import "CRVAssetType.h"

/**
 * The CRVImageAsset class is used to represent images which can be uploaded to
 * the carrierwave-powered server backend.
 */
@interface CRVImageAsset : NSObject <CRVAssetType>

/**
 * Creates the image asset using the data of an image. Designated initializer.
 *
 * If the image's MIME type is not specified, it will be guessed.
 *
 * @param image The data of the image to be represented by the asset.
 * @param name A file name to be associated with the asset, or nil.
 * @param type A MIME type to be associated with the asset, or nil.
 *
 * @return An initialized receiver.
 */
- (instancetype)initWithData:(NSData *)data fileName:(NSString *)name mimeType:(NSString *)type NS_DESIGNATED_INITIALIZER;

/**
 * Creates the image asset using the existing image instance.
 *
 * As the image's original MIME type is lost using this method, it is implicitly
 * converted to a PNG file.
 *
 * @param image The image to be represented by the asset.
 * @param name A file name to be associated with the asset, or nil.
 *
 * @return An initialized receiver.
 */
- (instancetype)initWithImage:(UIImage *)image fileName:(NSString *)name;

/**
 * Creates the image asset by loading a local image under the specified URL.
 *
 * The image's MIME type and file name are automatically computed.
 *
 * @param url The URL of a local image file to be represented by the asset.
 * @param error An error that occured while reading from the URL, if any.
 *
 * @return An initialized receiver.
 */
- (instancetype)initWithLocalURL:(NSURL *)url error:(NSError **)error;

/**
 * Asynchronously creates the image asset by fetching an image from remote URL.
 *
 * The image's MIME type and file name are automatically computed.
 *
 * @param url The URL of a remote image file to be represented by the asset.
 * @param completion The block to be executed on the completion of a request.
 */
+ (void)fetchAssetWithRemoteURL:(NSURL *)url completion:(void (^)(CRVImageAsset *asset, NSError *error))completion;

@end
