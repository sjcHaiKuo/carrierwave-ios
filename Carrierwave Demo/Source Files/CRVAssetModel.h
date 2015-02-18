//
//  CRVAssetModel.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 17.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import UIKit;
@import Carrierwave;

@interface CRVAssetModel : NSObject

- (instancetype)initWithImageAsset:(CRVImageAsset *)asset NS_DESIGNATED_INITIALIZER;

@property (strong, nonatomic) NSString *proccessIdentifier;
@property (strong, nonatomic) CRVImageAsset *asset;
@property (strong, nonatomic) CRVUploadInfo *uploadInfo;
@property (assign, nonatomic) double progress;

@property (assign, nonatomic, getter=isSuspended) BOOL suspended;
@property (assign, nonatomic, getter=isDownloaded) BOOL downloaded;
@property (assign, nonatomic, getter=isDowloading) BOOL downloading;
@property (assign, nonatomic, getter=isUploading) BOOL uploading;
@property (assign, nonatomic, getter=isDeleting) BOOL deleting;

- (BOOL)isUploaded;
- (void)clearState;

@end
