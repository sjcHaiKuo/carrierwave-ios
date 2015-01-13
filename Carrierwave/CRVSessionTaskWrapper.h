//
//  CRVSessionTask.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 12.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;

typedef void (^CRVSessionTaskProgress)(double);

@interface CRVSessionTaskWrapper : NSObject

- (instancetype)initWithProgress:(CRVSessionTaskProgress)progress;

@property (copy, nonatomic, readonly) CRVSessionTaskProgress progress;

@property (assign, nonatomic) NSUInteger retriesCount;

@end
