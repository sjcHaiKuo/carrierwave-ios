//
//  NSURLSessionTask+Carrierwave.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 20.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "NSURLSessionTask+Carrierwave.h"

@implementation NSURLSessionTask (Carrierwave)

- (double)crv_dowloadProgress {
    if (self.countOfBytesExpectedToReceive > 0) {
        return (double)self.countOfBytesReceived/(double)self.countOfBytesExpectedToReceive;
    }
    CRVTemporary("If response header doesn't contain Content-Length, it should be handle respectively.");
    return 0.0;
}

- (double)crv_uploadProgress {
    return (double)self.countOfBytesSent/(double)self.countOfBytesExpectedToSend;
}

@end
