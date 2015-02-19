//
//  CRVCollectionViewFlowLayout.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 19.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVCollectionViewFlowLayout.h"

@implementation CRVCollectionViewFlowLayout

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.sectionInset = UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f);
        self.minimumLineSpacing = 10.f;
        self.minimumInteritemSpacing = 10.f;
    }
    return self;
    
}

@end
