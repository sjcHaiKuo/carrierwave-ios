//
//  CRVVideoFileStreamProvider.h
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;

#import "CRVVideoStreamProvider.h"

@interface CRVVideoFileStreamProvider : NSObject <CRVVideoStreamProvider>

@property (strong, nonatomic, readonly) NSURL *fileURL;

- (instancetype)initWithFileUrl:(NSURL *)url NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFilePath:(NSString *)filePath;

@end
