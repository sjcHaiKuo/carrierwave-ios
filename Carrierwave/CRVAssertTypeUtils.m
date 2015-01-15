//
//  CRVAssertTypeUtils.m
//  Carrierwave
//
//  Created by Wojciech Trzasko on 15.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVAssertTypeUtils.h"

@implementation CRVAssertTypeUtils

+ (NSString *)fileExtensionByGuessingFromMimeType:(NSString *)mimeType {
    
    // inspired by AFNetworking/AFNetworking/AFURLRequestSerialization.m
    
    // try to guess the type
    CFStringRef cfMimeType = (__bridge CFStringRef)(mimeType);
    CFStringRef cfUti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, cfMimeType, NULL);
    NSString *ext = (__bridge_transfer NSString *)(UTTypeCopyPreferredTagWithClass(cfUti, kUTTagClassFilenameExtension));
    CFRelease(cfUti);
    
    // successful guess
    if (ext != nil) {
        return ext;
    }
    
    // default
    return nil;
}

+ (NSString *)fileNameForMimeType:(NSString *)mimeType {
    NSString *baseName = [NSUUID UUID].UUIDString;
    NSString *extension = [self fileExtensionByGuessingFromMimeType:mimeType];
    
    return [NSString stringWithFormat:@"%@.%@", baseName, extension];
}

@end
