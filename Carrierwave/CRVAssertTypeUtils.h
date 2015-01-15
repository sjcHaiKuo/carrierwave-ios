//
//  CRVAssertTypeUtils.h
//  Carrierwave
//
//  Created by Wojciech Trzasko on 15.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import CoreFoundation;
@import MobileCoreServices;
@import UIKit;

@interface CRVAssertTypeUtils : NSObject

+ (NSString *)fileExtensionByGuessingFromMimeType:(NSString *)mimeType;
+ (NSString *)fileNameForMimeType:(NSString *)mimeType;

@end
