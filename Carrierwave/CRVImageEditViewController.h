//
//  CRVImageEditViewController.h
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import CoreImage;
@import UIKit;

@class CRVImageAsset;
@protocol CRVImageEditViewControllerDelegate;

/**
 * The CRVImageCropViewController provides an easy user interface to move and
 * crop an image asset, similar to the build-in Photos app.
 */
IB_DESIGNABLE @interface CRVImageEditViewController : UIViewController

/**
 * Creates the crop view controllew with an image asset.
 *
 * @param asset The image asset to be cropped.
 *
 * @return An initialized receiver.
 */
- (instancetype)initWithImageAsset:(CRVImageAsset *)asset NS_DESIGNATED_INITIALIZER;

/**
 * The original image asset to be cropped.
 */
@property (strong, nonatomic) CRVImageAsset *imageAsset;

/**
 * The maximal allowed zoom of the image (default: 3x).
 */
@property (assign, nonatomic) IBInspectable CGFloat maximalZoom;

/**
 * Whether or not the cropped image should also be upscaled to match the
 * original image dimensions (default: no).
 */
@property (assign, nonatomic) IBInspectable BOOL preserveOriginalImageSize;

/**
 * The crop view controller's delegate object.
 */
@property (weak, nonatomic) IBOutlet id<CRVImageEditViewControllerDelegate> delegate;

@end

@protocol CRVImageCropViewControllerDelegate <NSObject> @optional

/**
 * Called when the user finishes cropping the image.
 *
 * @param ctrl The crop view controller sending the delegate message.
 * @param asset The new image asset representing the cropped image.
 */
- (void)imageEditViewController:(CRVImageEditViewController *)ctrl didFinishCroppingWithImageAsset:(CRVImageAsset *)asset;

/**
 * Called when the user cancels cropping the image.
 *
 * @param ctrl The crop view controller sending the delegate message.
 */
- (void)imageEditViewControllerDidCancelCropping:(CRVImageEditViewController *)ctrl;

@end
