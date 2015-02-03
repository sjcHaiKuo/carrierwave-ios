//
//  CRVSessionTaskWrapper+Carrierwave.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 03.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionTaskWrapper.h"

@interface CRVSessionTaskWrapper (Carrierwave)

/**
 *  Checks class type of wrapper.
 *
 *  @return Returns YES if wrapper is CRVSessionDownloadTaskWrapper class. NO otherwise.
 */
- (BOOL)isDownloadTask;

/**
 *  Checks class type of specified wrapper.
 *
 *  @return Returns YES if wrapper is CRVSessionUploadTaskWrapper class. NO otherwise.
 */
- (BOOL)isUploadTask;

@end
