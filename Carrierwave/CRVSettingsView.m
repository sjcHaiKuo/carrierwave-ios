//
//  CRVSettings.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 24.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSettingsView.h"
#import "CRVNotificationIdentifiers.h"

@implementation CRVSettingsView

- (void)performCancelAction {
    [self postNotificationWithName:CRVEditViewControllerWillCancelEditingNotification];
}

- (void)performDoneAction {
    [self postNotificationWithName:CRVEditViewControllerWillFinishEditingWithImageAssetNotification];
}

- (void)showRatioSheet {
    [self postNotificationWithName:CRVEditViewControllerWillShowRatioAlertController];
}

- (void)resetTransform {
    [self postNotificationWithName:CRVEditViewControllerWillResetImageAssetTransformationNotification];
}

#pragma mark - Private methods

- (void)postNotificationWithName:(NSString *)name {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}

@end
