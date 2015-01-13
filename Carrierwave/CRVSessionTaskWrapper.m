//
//  CRVSessionTask.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 12.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionTaskWrapper.h"

@implementation CRVSessionTaskWrapper

- (instancetype)initWithProgress:(CRVSessionTaskProgress)progress {
    self = [super init];
    if (self) {
        _retriesCount = 0;
        _progress = progress;
    }
    return self;
}

@end
