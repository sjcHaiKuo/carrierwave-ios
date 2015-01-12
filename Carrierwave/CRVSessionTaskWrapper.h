//
//  CRVSessionTask.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 12.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;

typedef void (^CRVProgressBlock)(NSURLSessionTask *);
typedef void (^CRVDownloadCompletionBlock)(NSData *, NSError *);
typedef void (^CRVUploadCompletionBlock)(BOOL, NSError *);

typedef NS_ENUM(NSInteger, CRVSessionTaskWrapperType) {
    CRVSessionTaskWrapperTypeUpload,
    CRVSessionTaskWrapperTypeDownload
};

@interface CRVSessionTaskWrapper : NSObject

- (instancetype)initWithUploadTask:(NSURLSessionUploadTask *)task progressBlock:(CRVProgressBlock)progressBlock completionBlock:(CRVUploadCompletionBlock)completionBlock;

- (instancetype)initWithDownloadTask:(NSURLSessionDownloadTask *)task progressBlock:(CRVProgressBlock)progressBlock completionBlock:(CRVDownloadCompletionBlock)completionBlock;

- (NSData *)resumeData;

- (BOOL)isDownloadIncomplete;

@property (strong, nonatomic) NSURLSessionTask *task;

@property (assign, nonatomic, readonly) CRVSessionTaskWrapperType type;

@property (copy, nonatomic, readonly) CRVProgressBlock progressBlock;

@property (copy, nonatomic, readonly) CRVDownloadCompletionBlock downloadCompletionBlock;

@property (copy, nonatomic, readonly) CRVUploadCompletionBlock uploadCompletionBlock;

@property (assign, nonatomic) NSUInteger reconnectionCount;

@end
