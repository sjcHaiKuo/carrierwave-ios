//
//  CRVSettingsController.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 25.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;

/**
 *  Settings messenger is responsible for posting messages to imageEditViewController or transformViewController.
 */

@interface CRVSettingsMessenger : NSObject

/**
 *  Tells CRVImageEditViewController to perform imageEditViewControllerDidCancelEditing: delegate.
 */
- (void)postCancelMessage;

/**
 *  Tells CRVImageEditViewController to perform imageEditViewController:didFinishEditingWithImageAsset: delegate.
 */
- (void)postDoneMessage;

/**
 *  Tells CRVImageEditViewController to show UIAlertController with ratio selection.
 */
- (void)postShowRatioSheetMessage;

/**
 *  Tells CRVTransformViewController to reset all transformation made by user.
 */
- (void)postResetTransformationMessage;

@end
