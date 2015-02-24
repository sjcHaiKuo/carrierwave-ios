//
//  CRVImageEditViewController.h
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import UIKit;

#import "CRVScalableView.h"
#import "CRVImageEditSettingsView.h"

@class CRVImageAsset, CRVSettingsView;
@protocol CRVImageEditViewControllerDelegate, CRVImageEditViewControllerDataSource;

/**
 *  The CRVImageCropViewController provides an easy user interface to move and
 *  crop an image asset, similar to the build-in Photos app.
 */
IB_DESIGNABLE @interface CRVImageEditViewController : UIViewController

/**
 *  Creates the edit view controller with an image asset.
 *
 *  @param asset The image asset to be cropped.
 *
 *  @return An initialized receiver.
 */
- (instancetype)initWithImageAsset:(CRVImageAsset *)asset NS_DESIGNATED_INITIALIZER;

/**
 *  The original image asset to be edited.
 */
@property (strong, nonatomic) CRVImageAsset *imageAsset;

/**
 *  The scalable crop view that crops portion of the screen.
 */
@property (weak, nonatomic, readonly) CRVScalableView *cropView;

/**
 *  The crop view controller's delegate object.
 */
@property (weak, nonatomic) IBOutlet id<CRVImageEditViewControllerDelegate> delegate;

/**
 *  The crop view controller's
 */
@property (weak, nonatomic) IBOutlet id<CRVImageEditViewControllerDataSource> dataSource;

/**
 *  The crop view controller's settings view.
 */
- (CRVSettingsView *)settingsView;

@end

@protocol CRVImageEditViewControllerDataSource <NSObject>

@optional

/**
 *  Allows the delegate to specify settingsView height. If this method is implemented, the value it returns overrides default value which is equal to 80 points.
 *
 *  @param controller The edit view controller sending the delegate message.
 */
- (CGFloat)heightForSettingsViewInImageEditViewController:(CRVImageEditViewController *)controller;

/**
 *  Asks the delegate for a view object, conforming CRVImageEditSettingsActions protocol, to display as settings view.
 *
 *  @param controller The edit view controller sending the delegate message.
 */
- (CRVSettingsView *)settingsViewForImageEditViewController:(CRVImageEditViewController *)controller;

@end

@protocol CRVImageEditViewControllerDelegate <NSObject>

@optional

/**
 *  Called when the user finishes editing the image.
 *
 *  @param controller The edit view controller sending the delegate message.
 *  @param asset      The new image asset representing the edited image.
 */
- (void)imageEditViewController:(CRVImageEditViewController *)controller didFinishEditingWithImageAsset:(CRVImageAsset *)asset;

/**
 *  Called when the user cancels editing the image.
 *
 *  @param controller The edit view controller sending the delegate message.
 */
- (void)imageEditViewControllerDidCancelEditing:(CRVImageEditViewController *)controller;

@end
