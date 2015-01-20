//
//  CRVVideoAssetTypedefs.h
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@class AVPlayerItem;

/**
 *  The completion block of load video action.
 *
 *  @param videoItem    Video item created from current asset.
 *  @param error        An error that occured, if any.
 */
typedef void (^CRVVideoLoadCompletionBlock)(AVPlayerItem *videoItem, NSError *error);
