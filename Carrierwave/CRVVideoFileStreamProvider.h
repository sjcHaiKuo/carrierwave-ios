//
//  CRVVideoFileStreamProvider.h
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;

#import "CRVVideoStreamProvider.h"

@interface CRVVideoFileStreamProvider : NSObject <CRVVideoStreamProvider>

/**
 * Url to file which will be represented by input data stream.
 */
@property (strong, nonatomic, readonly) NSURL *fileURL;

/**
 * Creates the data stream provider using url to local file.
 *
 * @param url Url to local file.
 *
 * @return An initialized receiver.
 */
- (instancetype)initWithFileUrl:(NSURL *)url NS_DESIGNATED_INITIALIZER;

/**
 * Creates the data stream provider using url to local file.
 *
 * @param path Path string to local file.
 *
 * @return An initialized receiver.
 */
- (instancetype)initWithFilePath:(NSString *)filePath;

@end
