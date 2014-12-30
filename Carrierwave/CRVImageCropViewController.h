//
//  CRVImageCropViewController.h
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import UIKit;

@class CRVImageAsset;
@protocol CRVImageCropViewControllerDelegate;

/**
 * The CRVImageCropViewController provides an easy user interface to rotate and
 * crop an image asset, similar to the build-in Photos app.
 */
IB_DESIGNABLE @interface CRVImageCropViewController : UIViewController

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
 * The crop view controller's delegate object.
 */
@property (weak, nonatomic) IBOutlet id<CRVImageCropViewControllerDelegate> delegate;

@end

@protocol CRVImageCropViewControllerDelegate <NSObject> @optional

/**
 * Called when the user finishes cropping the image.
 *
 * @param ctrl The crop view controller sending the delegate message.
 * @param asset The new image asset representing the cropped image.
 */
- (void)imageCropViewController:(CRVImageCropViewController *)ctrl didFinishCroppingWithImageAsset:(CRVImageAsset *)asset;

/**
 * Called when the user cancels cropping the image.
 *
 * @param ctrl The crop view controller sending the delegate message.
 */
- (void)imageCropViewControllerDidCancelCropping:(CRVImageCropViewController *)ctrl;

@end
