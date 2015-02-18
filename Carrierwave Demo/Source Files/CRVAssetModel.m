//
//  CRVAssetModel.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 17.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVAssetModel.h"

@implementation CRVAssetModel

- (instancetype)initWithImageAsset:(CRVImageAsset *)asset {
    self = [super init];
    if (self) {
        _asset = asset;
        self.downloading = NO;
        self.uploading = NO;
        self.progress = 0;
    }
    return self;
}

- (BOOL)isUploaded {
    return self.uploadInfo != nil;
}

- (void)clearState {
    self.suspended = NO; self.downloading = NO; self.uploading = NO; self.proccessIdentifier = nil;
}

@end
