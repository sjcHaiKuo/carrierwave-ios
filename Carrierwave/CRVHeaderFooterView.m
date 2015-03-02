//
//  CRVHeaderFooterView.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 25.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVHeaderFooterView.h"

@implementation CRVHeaderFooterView

- (instancetype)init {
    self = [super init];
    if (self) {
        _messenger = [[CRVEventMessenger alloc] init];
    }
    return self;
}

@end
