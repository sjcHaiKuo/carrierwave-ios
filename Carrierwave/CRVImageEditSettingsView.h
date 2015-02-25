//
//  CRVImageEditSettingsView.h
//  Carrierwave
//
//  Created by Paweł Białecki on 12.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSettingsView.h"

@interface CRVImageEditSettingsView : CRVSettingsView

/**
 *  Performs cancel action from CRVSettingsView
 */
@property (strong, nonatomic) UIButton *cancelButton;

/**
 *  Performs ratio action from CRVSettingsView
 */
@property (strong, nonatomic) UIButton *ratioButton;

/**
 *  Performs done action from CRVSettingsView
 */
@property (strong, nonatomic) UIButton *doneButton;

/**
 *  Performs reset transform action from CRVSettingsView
 */
@property (strong, nonatomic) UIButton *resetTransformButton;

@end
