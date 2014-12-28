//
//  CRVImageAsset.m
//  
//  Copyright (c) 2014 Netguru Sp. z o.o. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "CRVImageAsset.h"

@interface CRVImageAsset ()

@property (strong, nonatomic, readwrite) NSString *mimeType;
@property (strong, nonatomic, readwrite) NSString *fileName;
@property (strong, nonatomic, readwrite) NSData *data;

- (NSString *)mimeTypeByGuessingFromData:(NSData *)data;
- (NSString *)mimeTypeByGuessingFromURL:(NSURL *)url;

@end

#pragma mark -

@implementation CRVImageAsset

#pragma mark - Object lifecycle

- (instancetype)initWithData:(NSData *)data fileName:(NSString *)name mimeType:(NSString *)type {
    self = [super init];
    if (self == nil) return nil;
    self.data = data;
    self.fileName = name;
    self.mimeType = type;
    return self;
}

- (instancetype)initWithImage:(UIImage *)image fileName:(NSString *)name {
    return [self initWithData:UIImagePNGRepresentation(image) fileName:name mimeType:nil];
}

- (instancetype)initWithLocalURL:(NSURL *)url error:(NSError * __autoreleasing *)error {
    if (![url isFileURL]) {
        if (error != NULL) {
            NSDictionary *userInfo = @{ NSLocalizedFailureReasonErrorKey: @"Expected URL to be a file URL" };
            *error = [NSError errorWithDomain:@"CRVErrorDomain" code:NSURLErrorBadURL userInfo:userInfo];
        }
        return nil;
    } else if (![url checkResourceIsReachableAndReturnError:nil]) {
        if (error != NULL) {
            NSDictionary *userInfo = @{ NSLocalizedFailureReasonErrorKey: @"Expected URL to be reachable" };
            *error = [NSError errorWithDomain:@"CRVErrorDomain" code:NSURLErrorBadURL userInfo:userInfo];
        }
        return nil;
    }
    NSString *fileName = [url lastPathComponent];
    NSString *mimeType = [self mimeTypeByGuessingFromURL:url];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    return [self initWithData:data fileName:fileName mimeType:mimeType];
}

- (instancetype)init {
    return [self initWithData:nil fileName:nil mimeType:nil];
}

#pragma mark - Asynchronous fetch

+ (void)fetchAssetWithRemoteURL:(NSURL *)url completion:(void (^)(CRVImageAsset *, NSError *))completion {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, NSData *responseData) {
        NSString *fileName = operation.response.URL.lastPathComponent;
        NSString *mimeType = operation.response.MIMEType;
        CRVImageAsset *asset = [[self alloc] initWithData:responseData fileName:fileName mimeType:mimeType];
        if (completion != NULL) completion(asset, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion != NULL) completion(nil, error);
    }];
}

#pragma mark - Guessing mime types

- (NSString *)mimeTypeByGuessingFromData:(NSData *)data {

    // inspired by php/php-src/ext/standard/image.c

    // read bytes
    char bytes[12] = {0};
    [data getBytes:&bytes length:12];

    // initialize signatures
    const char bmp[2] = {'B', 'M'};
    const char gif[3] = {'G', 'I', 'F'};
    const char swf[3] = {'F', 'W', 'S'};
    const char swc[3] = {'C', 'W', 'S'};
    const char jpg[3] = {0xff, 0xd8, 0xff};
    const char jpc[3] = {0xff, 0x4f, 0xff};
    const char psd[4] = {'8', 'B', 'P', 'S'};
    const char iff[4] = {'F', 'O', 'R', 'M'};
    const char ico[4] = {0x00, 0x00, 0x01, 0x00};
    const char tif_ii[4] = {'I','I', 0x2A, 0x00};
    const char tif_mm[4] = {'M','M', 0x00, 0x2A};
    const char png[8] = {0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a};
    const char jp2[12] = {0x00, 0x00, 0x00, 0x0c, 0x6a, 0x50, 0x20, 0x20, 0x0d, 0x0a, 0x87, 0x0a};

    // try to guess by signatures
    if (!memcmp(bytes, bmp, 2)) {
        return @"image/x-ms-bmp";
    } else if (!memcmp(bytes, gif, 3)) {
        return @"image/gif";
    } else if (!memcmp(bytes, swf, 3) || !memcmp(bytes, swc, 3)) {
        return @"application/x-shockwave-flash";
    } else if (!memcmp(bytes, jpg, 3)) {
        return @"image/jpeg";
    } else if (!memcmp(bytes, jpc, 3)) {
        return @"image/octet-stream";
    } else if (!memcmp(bytes, psd, 4)) {
        return @"image/psd";
    } else if (!memcmp(bytes, iff, 4)) {
        return @"image/iff";
    } else if (!memcmp(bytes, ico, 4)) {
        return @"image/vnd.microsoft.icon";
    } else if (!memcmp(bytes, tif_ii, 4) || !memcmp(bytes, tif_mm, 4)) {
        return @"image/tiff";
    } else if (!memcmp(bytes, png, 8)) {
        return @"image/png";
    } else if (!memcmp(bytes, jp2, 12)) {
        return @"image/jp2";
    }

    // default
    return @"application/octet-stream";

}

- (NSString *)mimeTypeByGuessingFromURL:(NSURL *)url {

    // inspired by AFNetworking/AFNetworking/AFURLRequestSerialization.m

    // try to guess the type
    CFStringRef cfExtension = (__bridge CFStringRef)([url pathExtension]);
    CFStringRef cfUti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, cfExtension, NULL);
    NSString *type = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(cfUti, kUTTagClassMIMEType));

    // successful guess
    if (type != nil) {
        return type;
    }

    // default
    return @"application/octet-stream";
}


#pragma mark - Property accessors

- (NSString *)mimeType {
    if (_mimeType != nil) return _mimeType;
    return _mimeType = [self mimeTypeByGuessingFromData:self.data];
}

@end
