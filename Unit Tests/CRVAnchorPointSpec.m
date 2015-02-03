//
//  CRVAnchorPointSpec.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 29.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVAnchorPointSpec)

describe(@"CRVAnchorPointSpec", ^{
    
    __block CRVAnchorPoint *anchorPoint = nil;
    
    context(@"when newly created, ", ^{
        
        
        
        describe(@"with center location, ", ^{
            
            beforeEach(^{
                anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationCenter];
            });
            
            it(@"it should be initialized with center location in property.", ^{
                expect(anchorPoint.location).to.equal(CRVAnchorPointLocationCenter);
                expect(anchorPoint.location).toNot.equal(CRVAnchorPointLocationMiddleRight);
            });
        });
        
        
        
        describe(@"with some other location than center, ", ^{
            
            CRVAnchorPointLocation otherLocation = CRVAnchorPointLocationBottomRight;
            
            beforeEach(^{
                anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:otherLocation];
            });
            
            it(@"it should be initialized with some other location than center.", ^{
                expect(anchorPoint.location).toNot.equal(CRVAnchorPointLocationCenter);
                expect(anchorPoint.location).to.equal(otherLocation);
            });
        });
        
    });
    
});

SpecEnd
