//
//  CRVNetworkTypedefs.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 14.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;
@class CRVImageAsset, CRVUploadInfo;

typedef void (^CRVDownloadCompletionBlock)(CRVImageAsset *asset, NSError *error);
typedef void (^CRVUploadCompletionBlock)(CRVUploadInfo *info, NSError *error);
typedef void (^CRVCompletionBlock)(BOOL success, NSError *error);
typedef void (^CRVProgressBlock)(double progress);
typedef void (^CRVDataCompletionBlock)(NSData *data, NSError *error);

