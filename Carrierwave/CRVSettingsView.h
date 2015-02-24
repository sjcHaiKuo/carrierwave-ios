//
//  CRVSettings.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 24.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import UIKit;

/**
 *  Setting view is responsible for communication with controller by performing appropriate actions.
 *  Sublass it to inject own UI.
 */
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
- (void)showRatioSheet;

@end
