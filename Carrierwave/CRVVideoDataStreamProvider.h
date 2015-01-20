//
//  CRVVideoDataStreamProvider.h
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;

#import "CRVVideoStreamProvider.h"

@interface CRVVideoDataStreamProvider : NSObject <CRVVideoStreamProvider>

/**
 * NSData representation of provided object.
 */
@property (strong, nonatomic, readonly) NSData *data;

/**
 * Creates the data stream provider using raw data of object.
 *
 * @param data Raw data saved in NSData object.
 *
 * @return An initialized receiver.
 */
- (instancetype)initWithData:(NSData *)data NS_DESIGNATED_INITIALIZER;

@end
