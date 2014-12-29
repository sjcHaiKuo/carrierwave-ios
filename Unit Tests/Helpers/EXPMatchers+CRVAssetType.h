//
//  EXPMatchers+CRVAssetType.h
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

/**
 * Asserts that an asset has the expected MIME type.
 */
EXPMatcherInterface(crv_haveMimeTypeOf, (NSString *expected));

/**
 * Asserts that an asset has the expected file extension.
 */
EXPMatcherInterface(crv_haveFileExtensionOf, (NSString *expected));
