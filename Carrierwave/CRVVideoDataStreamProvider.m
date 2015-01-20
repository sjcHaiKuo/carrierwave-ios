//
//  CRVVideoDataStreamProvider.m
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVVideoDataStreamProvider.h"

@interface CRVVideoDataStreamProvider ()

@property (strong, nonatomic, readwrite) NSData *data;

@end

@implementation CRVVideoDataStreamProvider

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        self.data = data;
    }
    return self;
}

- (NSInputStream *)inputStream {
    return [NSInputStream inputStreamWithData:self.data];
}

- (NSNumber *)inputStreamLength {
    return @(self.data.length);
}

@end
