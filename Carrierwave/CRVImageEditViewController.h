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
 * Creates the edit view controller with an image asset.
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
 * The minimum allowed zoom of the image. Default 0.1.
 */
@property (assign, nonatomic) IBInspectable CGFloat minimumZoom;

/**
 * The maximal allowed zoom of the image. Default 2.0.
 */
@property (assign, nonatomic) IBInspectable CGFloat maximalZoom;

/**
 * The slider item that rotates the image.
 */
@property (strong, nonatomic, readonly) UISlider *rotationSlider;

/**
 * The bar button item that sends a cancel mesage.
 */
@property (strong, nonatomic, readonly) UIBarButtonItem *cancelBarButtonItem;

/**
 * The bar button item that opens an action sheet for choosing aspect ratio.
 */
@property (strong, nonatomic, readonly) UIBarButtonItem *ratioBarButtonItem;

/**
 * The bar button item that sends a done message.
 */
@property (strong, nonatomic, readonly) UIBarButtonItem *doneBarButtonItem;

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
