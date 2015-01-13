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

/**
 *  Designed initializer for CRVSessionTaskWrapper class.
 *
 *  @param progress The progress block invoked every time when task will receive data.
 *
 *  @return An initialized receiver.
 */
- (instancetype)initWithProgress:(CRVSessionTaskProgress)progress NS_DESIGNATED_INITIALIZER;

/**
 *  A progress block which is invoked every time when task will receive data.
 *  Holds reference to appropriate asset progress block.
 */
@property (copy, nonatomic, readonly) CRVSessionTaskProgress progress;

/**
 *  Count of connection retries incremented after every task download/upload failure
 */
@property (assign, nonatomic) NSUInteger retriesCount;

@end
