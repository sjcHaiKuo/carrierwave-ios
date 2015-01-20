//
//  CRVSessionUploadTaskWrapper.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 13.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionUploadTaskWrapper.h"

@implementation CRVSessionUploadTaskWrapper

- (instancetype)initWithTask:(NSURLSessionTask *)task identifier:(NSUInteger)identifier progress:(CRVProgressBlock)progress completion:(CRVUploadCompletionResponseBlock)completion {
    self = [self initWithTask:task identifier:identifier progress:progress];
    if (self) {
        _completion = completion;
    }
    return self;
}

@end
