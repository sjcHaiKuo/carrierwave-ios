//
//  CRVVideoDataStreamProvider.h
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;

#import "CRVVideoStreamProvider.h"

@interface CRVVideoDataStreamProvider : NSObject <CRVVideoStreamProvider>

@property (strong, nonatomic, readonly) NSData *data;

- (instancetype)initWithData:(NSData *)data;

@end
