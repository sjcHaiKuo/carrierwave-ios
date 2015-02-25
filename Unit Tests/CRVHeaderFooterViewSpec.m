//
//  CRVHeaderFooterViewSpec.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 25.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVHeaderFooterViewSpec)

describe(@"CRVHeaderFooterView", ^{
    
    __block CRVHeaderFooterView *sut;
    
    context(@"when newly created", ^{
        
        beforeEach(^{
            sut = [[CRVHeaderFooterView alloc] init];
        });
        
        afterEach(^{
            sut = nil;
        });
        
        it(@"should not be nil", ^{
            expect(sut).toNot.beNil();
        });
        
        it(@"should have a settings messenger", ^{
            expect(sut.messenger).to.beKindOf([CRVSettingsMessenger class]);
            expect(sut.messenger).toNot.beNil();
        });
        
    });
});

SpecEnd
