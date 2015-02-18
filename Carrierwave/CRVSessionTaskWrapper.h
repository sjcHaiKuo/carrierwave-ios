//
//  CRVSessionTask.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 12.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVNetworkTypedefs.h"

@interface CRVSessionTaskWrapper : NSObject

/**
 *  Designed initializer for CRVSessionTaskWrapper class.
 *
 *  @param task       The task which belongs to wrapper.
 *  @param identifier The identifier of wrapper.
 *  @param progress   The progress block invoked every time when task will receive data.
 *
 *  @return An initialized receiver.
 */
- (instancetype)initWithTask:(NSURLSessionTask *)task identifier:(NSString *)identifier progress:(CRVProgressBlock)progress NS_DESIGNATED_INITIALIZER;

/**
 *  File name which has been received from URL.
 *
 *  @return Guessed file name.
 */
- (NSString *)fileNameByGuessingFromURLPath;

/**
 *  Task around wrapper is build on.
 */
@property (strong, nonatomic) NSURLSessionTask *task;

/**
 *  A progress block which is invoked every time when task will receive data.
 *  Holds reference to appropriate asset progress block.
 */
@property (copy, nonatomic, readonly) CRVProgressBlock progress;

/**
 *  Count of connection retries incremented after every task download/upload failure.
 */
@property (assign, nonatomic) NSUInteger retriesCount;

/**
 *  An identifier for this wrapper, assigned by CRVSessionTaskManager and unique accross an app.
 */
@property (strong, nonatomic, readonly) NSString *identifier;

@end
