//
//  CRVVideoStreamProvider.h
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@protocol CRVVideoStreamProvider <NSObject> @required

@property (strong, nonatomic, readonly) NSInputStream *inputStream;
@property (strong, nonatomic, readonly) NSNumber *inputStreamLength;

@end
