//
//  CRVImageEditSettingsView.h
//  Carrierwave
//
//  Created by Paweł Białecki on 12.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVHeaderFooterView.h"

/**
 *  This is default footer UIView used by CRVEditImageViewController.
 *  If end-developer will not provide his own view for footer, this one will be used.
 *  Injecting own view is possible by implementing CRVImageEditViewControllerDelegate and method:
 *
 *  - (UIView *)viewForFooterInImageEditViewController:(CRVImageEditViewController *)controller;
 *
 *  Specifying header height is possible with:
 *
 *  - (CGFloat)heightForFooterInImageEditViewController:(CRVImageEditViewController *)controller;
 *
 *  Notice that this view inherits from CRVHeaderFooterView because footer view has to have a possibility to send messeges via settings messenger.
 */

@interface CRVFooterView : CRVHeaderFooterView

@end
