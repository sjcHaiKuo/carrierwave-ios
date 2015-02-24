//
//  CRVImageEditView.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 24.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import UIKit;

@protocol CRVImageEditSettingsActions;
@class CRVSettingsView;

@interface CRVImageEditView : UIView

/**
 *  A settings view which contain behaviour methods.
 */
@property (strong, nonatomic) CRVSettingsView *settingsView;

/**
 *  Defines height designed for settings view.
 */
@property (assign, nonatomic) CGFloat heightForSettingsView;

/**
 *  Calculates and returns rect designed for container view
 */
- (CGRect)rectForContainerView;

@end
