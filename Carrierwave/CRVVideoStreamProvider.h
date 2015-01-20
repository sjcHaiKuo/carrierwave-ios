//
//  CRVVideoStreamProvider.h
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@protocol CRVVideoStreamProvider <NSObject> @required

/**
 * The data stream of provided object.
 */
@property (strong, nonatomic, readonly) NSInputStream *inputStream;

/**
 * The length of input data stream.
 */
@property (strong, nonatomic, readonly) NSNumber *inputStreamLength;

@end
