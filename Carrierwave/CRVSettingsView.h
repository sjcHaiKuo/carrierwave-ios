//
//  CRVSettings.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 24.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import UIKit;

@interface CRVSettingsView : UIView

/**
 *  Tells CRVImageEditViewController to perform imageEditViewControllerDidCancelEditing: delegate.
 */
- (void)performCancelAction;

/**
 *  Tells CRVImageEditViewController to perform imageEditViewController:didFinishEditingWithImageAsset: delegate.
 */
- (void)performDoneAction;

/**
 *  Tells CRVImageEditViewController to show UIAlertController with ratio selection.
 */
- (void)showRatio;

@end
