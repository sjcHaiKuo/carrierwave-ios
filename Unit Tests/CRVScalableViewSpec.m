//
//  CRVScalableViewSpec.m
//  Carrierwave
//
//  Created by Paweł Białecki on 09.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVScalableView.h"

SpecBegin(CRVScalableViewSpec)

describe(@"CRVScalableViewSpec", ^{
    
    __block CRVScalableView *scalableView = nil;
    
    beforeEach(^{
        CGRect frame = CGRectMake(100, 100, 100, 100);
        scalableView = [[CRVScalableView alloc] initWithFrame:frame];
    });
    
    afterEach(^{
        scalableView = nil;
    });
    
    context(@"when newly created", ^{
        
        it(@"should be initialized", ^{
            expect(scalableView).toNot.beNil();
        });
        
        pending(@"it should be initialized properly");
    });
    
    describe(@"when setting minimal size", ^{
       
        pending(@"it should be done properly"); // it should raise exception
    });
});

SpecEnd
