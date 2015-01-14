//
//  CRVSessionTask.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 12.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionTaskWrapper.h"

@implementation CRVSessionTaskWrapper

- (instancetype)initWithTask:(NSURLSessionTask *)task identifier:(NSUInteger)identifier progress:(CRVProgressBlock)progress {
    self = [super init];
    if (self) {
        _task = task;
        _retriesCount = 0;
        _progress = progress;
        _identifier = identifier;
    }
    return self;
}

- (NSString *)fileNameByGuessingFromURLPath {
    return [[self.task.originalRequest.URL.path componentsSeparatedByString:@"/"] lastObject];
}

@end
