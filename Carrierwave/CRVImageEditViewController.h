//
//  CRVImageEditViewController.h
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import CoreGraphics;
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
 * Creates the edit view controllew with an image asset.
 *
 * @param asset The image asset to be cropped.
 *
 * @return An initialized receiver.
 */
- (instancetype)initWithImageAsset:(CRVImageAsset *)asset NS_DESIGNATED_INITIALIZER;

/**
 * The original image asset to be edited.
 */
@property (strong, nonatomic) CRVImageAsset *imageAsset;

/**
 * The maximal allowed zoom of the image (default: 3x).
 */
@property (assign, nonatomic) IBInspectable CGFloat maximalZoom;

/**
 * The crop view controller's delegate object.
 */
@property (weak, nonatomic) IBOutlet id<CRVImageEditViewControllerDelegate> delegate;

@end

@protocol CRVImageEditViewControllerDelegate <NSObject> @optional

/**
 * Called when the user finishes editing the image.
 *
 * @param ctrl The edit view controller sending the delegate message.
 * @param asset The new image asset representing the edited image.
 */
- (void)imageEditViewController:(CRVImageEditViewController *)ctrl didFinishEditingWithImageAsset:(CRVImageAsset *)asset;

/**
 * Called when the user cancels editing the image.
 *
 * @param ctrl The edit view controller sending the delegate message.
 */
- (void)imageEditViewControllerDidCancelEditing:(CRVImageEditViewController *)ctrl;

@end
