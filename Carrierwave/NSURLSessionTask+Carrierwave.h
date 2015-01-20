//
//  NSURLSessionTask+Carrierwave.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 20.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSessionTask (Carrierwave)

- (double)crv_dowloadProgress;

- (double)crv_uploadProgress;

@end
