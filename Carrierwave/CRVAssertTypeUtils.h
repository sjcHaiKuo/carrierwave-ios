//
//  CRVAssertTypeUtils.h
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import CoreFoundation;
@import MobileCoreServices;
@import UIKit;

@interface CRVAssertTypeUtils : NSObject

/**
 *  Determines file extension from mime type.
 *
 *  @param mimeType Mime type used to determine file extension.
 *
 *  @return File extension.
 */
+ (NSString *)fileExtensionByGuessingFromMimeType:(NSString *)mimeType;

/**
 *  Creates and returns an new file name.
 *
 *  @param mimeType Mime type used to determine file name.
 *
 *  @return New file name.
 */
+ (NSString *)fileNameForMimeType:(NSString *)mimeType;

@end
