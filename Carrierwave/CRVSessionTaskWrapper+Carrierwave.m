//
//  CRVSessionTaskWrapper+Carrierwave.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 03.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionTaskWrapper+Carrierwave.h"
#import "CRVSessionDownloadTaskWrapper.h"
#import "CRVSessionUploadTaskWrapper.h"

@implementation CRVSessionTaskWrapper (Carrierwave)

- (BOOL)isDownloadTask {
    return [self isKindOfClass:[CRVSessionDownloadTaskWrapper class]];
}

- (BOOL)isUploadTask {
    return [self isKindOfClass:[CRVSessionUploadTaskWrapper class]];
}

@end
