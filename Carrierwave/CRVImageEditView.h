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

@property (strong, nonatomic) CRVSettingsView *settingsView;
@property (assign, nonatomic) CGFloat heightForSettingsView;

- (CGRect)rectForContainerView;

@end
