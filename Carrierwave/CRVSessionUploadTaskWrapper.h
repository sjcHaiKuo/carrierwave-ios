//
//  CRVSessionUploadTaskWrapper.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 13.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionTaskWrapper.h"

@interface CRVSessionUploadTaskWrapper : CRVSessionTaskWrapper

/**
 *  Designed initializer for CRVSessionUploadTaskWrapper class.
 *
 *  @param task       The task which belongs to wrapper.
 *  @param progress   The progress block invoked every time when task will send data.
 *  @param completion The completion block invoked when task uploading will complete with success or error.
 *
 *  @return An initialized receiver.
 */
- (instancetype)initWithTask:(NSURLSessionTask *)task identifier:(NSUInteger)identifier progress:(CRVProgressBlock)progress completion:(CRVUploadCompletionBlock)completion;

/**
 *  The completion block invoked when task uploading will complete with success or break with an error.
 */
@property (copy, nonatomic, readonly) CRVUploadCompletionBlock completion;

/**
 *  Mime type of file to upload.
 */
@property (strong, nonatomic) NSString *mimeType;

/**
 *  Data stream representing file to upload.
 */
@property (strong, nonatomic) NSInputStream *dataStream;

/**
 *  Length of data stream.
 */
@property (strong, nonatomic) NSNumber *length;

/**
 *  Name of file to upload.
 */
@property (strong, nonatomic) NSString *name;

@end
