//
//  CRVNotificationIdentifiers.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 24.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#ifndef Carrierwave_CRVNotificationIdentifiers_h
#define Carrierwave_CRVNotificationIdentifiers_h

// Notifications observed by CRVImageEditViewController:
static NSString *const CRVImageEditViewControllerWillShowRatioAlertControllerNotification = @"CRVImageEditViewControllerWillShowRatioAlertControllerNotification";
static NSString *const CRVImageEditViewControllerWillCancelEditingNotification = @"CRVImageEditViewControllerWillCancelEditingNotification";
static NSString *const CRVImageEditViewControllerWillFinishEditingWithImageAssetNotification = @"CRVImageEditViewControllerWillFinishEditingWithImageAssetNotification";

// Notifications observed by CRVTransformViewController:
static NSString *const CRVTransformViewControllerWillResetTransformationNotification = @"CRVTransformViewControllerWillResetTransformationNotification";

#endif
