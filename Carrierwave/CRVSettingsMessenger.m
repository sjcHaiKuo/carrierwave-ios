//
//  CRVSettingsController.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 25.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSettingsMessenger.h"
#import "CRVNotificationIdentifiers.h"

@implementation CRVSettingsMessenger

- (void)postCancelMessage {
    [self postNotificationWithName:CRVImageEditViewControllerWillCancelEditingNotification];
}

- (void)postDoneMessage {
    [self postNotificationWithName:CRVImageEditViewControllerWillFinishEditingWithImageAssetNotification];
}

- (void)postShowRatioSheetMessage {
    [self postNotificationWithName:CRVImageEditViewControllerWillShowRatioAlertControllerNotification];
}

- (void)postResetTransformationMessage {
    [self postNotificationWithName:CRVTransformViewControllerWillResetTransformationNotification];
}

#pragma mark - Private methods

- (void)postNotificationWithName:(NSString *)name {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}

@end
