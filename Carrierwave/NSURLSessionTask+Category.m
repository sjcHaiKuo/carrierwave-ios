//
//  NSURLSessionTask+Category.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 09.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "NSURLSessionTask+Category.h"

@implementation NSURLSessionTask (Category)

- (double)crv_dowloadProgress {
    return (double)self.countOfBytesReceived/(double)self.countOfBytesExpectedToReceive;
}

- (double)crv_uploadProgress {
    return (double)self.countOfBytesSent/(double)self.countOfBytesExpectedToSend;
}

@end
