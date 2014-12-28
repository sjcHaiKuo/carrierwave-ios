//
//  Carrierwave-Macros.h
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#pragma mark - Warning macros

#ifndef ENV_TEST
    #define CRVWorkInProgress(m) _CRVPragma(message "[WIP] " m)
    #define CRVTemporary(m) _CRVPragma(message "[TEMP] " m)
#else
    #define CRVWorkInProgress(m)
    #define CRVTemporary(m)
#endif

#pragma mark - String macros

#define CRVLocalizedStringWithFormat(f, ...) \
    [NSString stringWithFormat:NSLocalizedString(f, nil), __VA_ARGS__]

#pragma mark - Private macros

#define _CRVPragma(p) _Pragma(#p)
