//
//  EXPMatchers+CRVAssetType.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "EXPMatchers+CRVAssetType.h"

EXPMatcherImplementationBegin(crv_haveMimeTypeOf, (NSString *expected)) {

    BOOL actualIsAsset = [actual conformsToProtocol:@protocol(CRVAssetType)];
    id<CRVAssetType> actualAsset = (id<CRVAssetType>)actual;

    prerequisite(^BOOL {
        return actualIsAsset;
    });

    match(^BOOL {
        return [actualAsset.mimeType isEqualToString:expected];
    });

    failureMessageForTo(^NSString * {
        NSString *expectedDescription = @"", *actualDescription = @"";
        if (!actualIsAsset) {
            expectedDescription = [NSString stringWithFormat:@"an instance of %@", [CRVImageAsset class]];
            actualDescription = [NSString stringWithFormat:@"an instance of %@", [actual class]];
        } else {
            expectedDescription = EXPDescribeObject(expected);
            actualDescription = EXPDescribeObject(actualAsset.mimeType);
        }
        return [NSString stringWithFormat:@"expected: %@, got: %@", expectedDescription, actualDescription];
    });

    failureMessageForNotTo(^NSString * {
        NSString *expectedDescription = @"", *actualDescription = @"";
        if (!actualIsAsset) {
            expectedDescription = [NSString stringWithFormat:@"an instance of %@", [CRVImageAsset class]];
            actualDescription = [NSString stringWithFormat:@"an instance of %@", [actual class]];
        } else {
            expectedDescription = EXPDescribeObject(expected);
            actualDescription = EXPDescribeObject(actualAsset.mimeType);
        }
        return [NSString stringWithFormat:@"expected: not %@, got: %@", expectedDescription, actualDescription];
    });

} EXPMatcherImplementationEnd

EXPMatcherImplementationBegin(crv_haveFileExtensionOf, (NSString *expected)) {

    BOOL actualIsAsset = [actual conformsToProtocol:@protocol(CRVAssetType)];
    id<CRVAssetType> actualAsset = (id<CRVAssetType>)actual;

    prerequisite(^BOOL {
        return actualIsAsset;
    });

    match(^BOOL {
        return [actualAsset.fileName.pathExtension isEqualToString:expected];
    });

    failureMessageForTo(^NSString * {
        NSString *expectedDescription = @"", *actualDescription = @"";
        if (!actualIsAsset) {
            expectedDescription = [NSString stringWithFormat:@"an instance of %@", [CRVImageAsset class]];
            actualDescription = [NSString stringWithFormat:@"an instance of %@", [actual class]];
        } else {
            expectedDescription = EXPDescribeObject(expected);
            actualDescription = EXPDescribeObject(actualAsset.fileName.pathExtension);
        }
        return [NSString stringWithFormat:@"expected: %@, got: %@", expectedDescription, actualDescription];
    });

    failureMessageForNotTo(^NSString * {
        NSString *expectedDescription = @"", *actualDescription = @"";
        if (!actualIsAsset) {
            expectedDescription = [NSString stringWithFormat:@"an instance of %@", [CRVImageAsset class]];
            actualDescription = [NSString stringWithFormat:@"an instance of %@", [actual class]];
        } else {
            expectedDescription = EXPDescribeObject(expected);
            actualDescription = EXPDescribeObject(actualAsset.fileName.pathExtension);
        }
        return [NSString stringWithFormat:@"expected: not %@, got: %@", expectedDescription, actualDescription];
    });

} EXPMatcherImplementationEnd
