//
//  KIFUITestActor+FunctionalTests.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 03.03.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "KIFUITestActor+FunctionalTests.h"

@implementation KIFUITestActor (FunctionalTests)

- (void)crv_tapCropButton {
    [self tapViewWithAccessibilityLabel:@"Crop"];
}

- (void)crv_tapUploadButton {
    [self tapViewWithAccessibilityLabel:@"Upload"];
}

- (void)crv_tapDownloadButton {
    [self tapViewWithAccessibilityLabel:@"Download"];
}

- (void)crv_tapPauseButton {
    [self tapViewWithAccessibilityLabel:@"Pause"];
}

- (void)crv_tapDeleteButton {
    [self tapViewWithAccessibilityLabel:@"Delete"];
}

- (void)crv_tapCancelButton {
    [self tapViewWithAccessibilityLabel:@"Cancel"];
}

- (void)crv_tapResumeButton {
    [self tapViewWithAccessibilityLabel:@"Resume"];
}

- (void)crv_tapCameraBarButton {
    [self tapViewWithAccessibilityLabel:@"Camera Bar Button"];
}

- (void)crv_openPhotoAlbum {
    [self crv_tapCameraBarButton];
    [self waitAndTapViewWithAccessibilityLabel:@"Photo Album"];
}

- (void)crv_closePhotoAlbum {
    [self waitAndTapViewWithAccessibilityLabel:@"Cancel"];
}

#pragma mark - Private Methods

- (void)waitAndTapViewWithAccessibilityLabel:(NSString *)label {
    [self waitForViewWithAccessibilityLabel:label];
    [self tapViewWithAccessibilityLabel:label];
}

@end
