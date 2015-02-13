//
//  CRVImageEditToolbar.h
//  Carrierwave
//
//  Created by Paweł Białecki on 12.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;

/**
 *  The CRVImageEditToolbar protocol provides a common interface for customizing the settings toolbar on the bottom of the CRVImageEdit screen.
 */
@protocol CRVImageEditToolbar <NSObject> @required

/**
 *  The color of the toolbar. Default black with 0.8f alpha.
 */
- (UIColor *)toolbarBackgroundColor;

/**
 *  The rotation slider used for rotating the image.
 *
 *  @return The rotation slider for use in the CRVImageEditViewController.
 */
- (UISlider *)rotationSlider;

/**
 *  The cancel bar button item used for canceling editing.
 *
 *  @return The cancel bar button item.
 */
- (UIBarButtonItem *)cancelBarButtonItem;

/**
 *  The ratio bar button item used for selecting the cropping frame aspect ratio.
 *
 *  @return The ratio bar button item.
 */
- (UIBarButtonItem *)ratioBarButtonItem;

/**
 *  The done bar button item used for sucessfully ending the editing of image.
 *
 *  @return The done bar button item.
 */
- (UIBarButtonItem *)doneBarButtonItem;

@end
