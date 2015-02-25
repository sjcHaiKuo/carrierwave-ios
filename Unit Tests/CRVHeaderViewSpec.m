//
//  CRVHeaderViewSpec.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 25.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVHeaderViewSpec)

describe(@"CRVHeaderView", ^{
    
    __block CRVHeaderView *sut;
    
    context(@"when newly created", ^{
        
        beforeEach(^{
            sut = [[CRVHeaderView alloc] init];
        });
        
        afterEach(^{
            sut = nil;
        });
        
        it(@"should not be nil", ^{
            expect(sut).toNot.beNil();
        });
        
        it(@"should inherits from UILabel class", ^{
            expect(sut).to.beKindOf([UILabel class]);
        });
    });
});

SpecEnd
