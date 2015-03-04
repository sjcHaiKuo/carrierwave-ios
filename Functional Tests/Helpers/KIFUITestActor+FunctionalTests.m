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
    [self acknowledgeSystemAlert];
}

- (void)crv_closePhotoAlbum {
    [self tapViewWithAccessibilityLabel:@"Cancel"];
}

- (void)crv_tapResetButton {
    [self tapViewWithAccessibilityLabel:@"Reset"];
}

- (void)crv_tapRatioButton {
    [self tapViewWithAccessibilityLabel:@"Ratio"];
}

- (void)crv_tapDoneButton {
    [self tapViewWithAccessibilityLabel:@"Done"];
}

- (void)crv_doubleTapInCropView {
    UIView *view = [self waitForViewWithAccessibilityLabel:@"Scalable View"];
    [tester tapScreenAtPoint:view.center];
    [tester waitForTimeInterval:0.1];
    [tester tapScreenAtPoint:view.center];
    [tester waitForTimeInterval:2];
}

- (void)crv_moveCropImageView {
    UIView *view = [self waitForViewWithAccessibilityLabel:@"Crop Image View"];
    
    CGRect newFrame = view.frame;
    newFrame.origin = CGPointMake(-20, 100);
    
    CGAffineTransform transform = CGAffineTransformScale(view.transform, 0.4, 0.4);
    transform = CGAffineTransformRotate(transform, M_PI/2.5);
    
    [UIView animateWithDuration:1 animations:^{
        view.frame = newFrame;
        view.transform = transform;
    }];
    [self waitForTimeInterval:2];
}

- (void)waitAndTapViewWithAccessibilityLabel:(NSString *)label {
    [self waitForViewWithAccessibilityLabel:label];
    [self tapViewWithAccessibilityLabel:label];
}

@end
