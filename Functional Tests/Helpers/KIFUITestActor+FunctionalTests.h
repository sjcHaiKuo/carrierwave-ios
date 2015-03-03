//
//  KIFUITestActor+FunctionalTests.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 03.03.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "KIFUITestActor.h"

@interface KIFUITestActor (FunctionalTests)

- (void)crv_tapCropButton;

- (void)crv_tapUploadButton;

- (void)crv_tapDownloadButton;

- (void)crv_tapPauseButton;

- (void)crv_tapDeleteButton;

- (void)crv_tapCancelButton;

- (void)crv_tapResumeButton;

- (void)crv_tapCameraBarButton;

- (void)crv_openPhotoAlbum;

- (void)crv_closePhotoAlbum;

@end
