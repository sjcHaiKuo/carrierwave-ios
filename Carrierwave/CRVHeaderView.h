//
//  CRVInfoView.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 24.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import UIKit;

/**
 *  This is default header UIView used by CRVEditImageViewController.
 *  If end-developer will not provide his own view for header, this one will be used.
 *  Injecting own view is possible by implementing CRVImageEditViewControllerDelegate and method:
 * 
 *  - (UIView *)viewForHeaderInImageEditViewController:(CRVImageEditViewController *)controller;
 *
 *  Specifying header height is possible with:
 *
 *  - (CGFloat)heightForHeaderInImageEditViewController:(CRVImageEditViewController *)controller;
 */

@interface CRVHeaderView : UILabel

@end
