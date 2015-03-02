//
//  CRVImageEditViewController.h
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import UIKit;

#import "CRVScalableView.h"
#import "CRVHeaderFooterView.h"
#import "CRVRatioItem.h"

@class CRVImageAsset;
@protocol CRVImageEditViewControllerDelegate;

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
 *  An array populated with CRVRatioItem objects used to display UIAlertController.
 */
@property (strong, nonatomic, readonly) NSArray *ratioItemList;

/**
 *  Adds an item to list which populates UIAlertController actions. Use it to add your own ratios to crop view should scale.
 *
 *  @param ratioItem An item added to list. Provide ratio and title as well.
 */
- (void)addRatioItemToList:(CRVRatioItem *)ratioItem;

/**
 *  Header view layouted at the top of CRVImageEditViewController's view. By default returns UILabel with short info.
 */
- (UIView *)headerView;

/**
 *  Footer view layouted at the bottom of CRVImageEditViewController's view. By default returns UIView with events buttons.
 */
- (UIView *)footerView;

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

/**
 *  Asks the delegate for a view to display as header view (at the top of CRVImageEditViewController's view).
 *  If not implemented, the default one will be used. Pass nil if header view should not be initialized.
 *  To create a view with communication feature, sublass CRVHeaderFooterView and use eventMessenger to post messages.
 *
 *  @param controller The edit view controller which will display header view.
 */
- (UIView *)viewForHeaderInImageEditViewController:(CRVImageEditViewController *)controller;

/**
 *  Asks the delegate for a view to display as footer view (at the bottom of CRVImageEditViewController's view).
 *  If not implemented, the default one will be used. Pass nil if footer view should not be initialized.
 *  To create a view with communication feature, sublass CRVHeaderFooterView and use eventMessenger to post messages.
 *
 *  @param controller The edit view controller which will display footer view.
 */
- (UIView *)viewForFooterInImageEditViewController:(CRVImageEditViewController *)controller;

/**
 *  Allows the delegate to specify header view height. If this method is implemented, the value it returns overrides default value which is equal to 20 points.
 *
 *  @param controller The edit view controller sending the delegate message.
 */
- (CGFloat)heightForHeaderInImageEditViewController:(CRVImageEditViewController *)controller;

/**
 *  Allows the delegate to specify footer height. If this method is implemented, the value it returns overrides default value which is equal to 60 points.
 *
 *  @param controller The edit view controller sending the delegate message.
 */
- (CGFloat)heightForFooterInImageEditViewController:(CRVImageEditViewController *)controller;

@end
