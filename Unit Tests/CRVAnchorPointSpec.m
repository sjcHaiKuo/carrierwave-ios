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
    
    context(@"when newly created", ^{
        
        before(^{
            anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationCenter];
        });
        
        it(@"it should have 9 CRVAnchorPointLocation enum elements", ^{
            expect(CRVAnchorPointLocationPointsCount).to.equal(9);
        });
        
        it(@"it should not have nils in properties", ^{
            expect(anchorPoint.adjustsH).notTo.beNil;
            expect(anchorPoint.adjustsW).notTo.beNil;
            expect(anchorPoint.adjustsX).notTo.beNil;
            expect(anchorPoint.adjustsY).notTo.beNil;
            expect(anchorPoint.ratioH).notTo.beNil;
            expect(anchorPoint.ratioW).notTo.beNil;
            expect(anchorPoint.ratioX1).notTo.beNil;
            expect(anchorPoint.ratioX2).notTo.beNil;
            expect(anchorPoint.ratioY1).notTo.beNil;
            expect(anchorPoint.ratioY2).notTo.beNil;
        });
        
        context(@"with center location", ^{
            
            CRVAnchorPointLocation centerLocation = CRVAnchorPointLocationCenter;
            
            beforeEach(^{
                anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:centerLocation];
            });
            
            it(@"it should be initialized with center location in the property", ^{
                expect(anchorPoint.location).to.equal(centerLocation);
            });
            
            it(@"it should be not initialized with some other location than center in the property", ^{
                expect(anchorPoint.location).toNot.equal(CRVAnchorPointLocationMiddleRight);
            });
        });
        
        context(@"with some other location than center", ^{
            
            CRVAnchorPointLocation otherLocation = CRVAnchorPointLocationBottomRight;
            
            beforeEach(^{
                anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:otherLocation];
            });
            
            it(@"it should be initialized with some other location than center", ^{
                expect(anchorPoint.location).to.equal(otherLocation);
            });
            
            it(@"it should be not initialized with center location", ^{
                expect(anchorPoint.location).toNot.equal(CRVAnchorPointLocationCenter);
            });
        });
        
    });
    
    context(@"after setting referencePoint property", ^{
        
        before(^{
            anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationCenter];
            CGSize size = CGSizeMake(50, 100);
            [anchorPoint setReferencePointWithSize:size];
        });
        
        it(@"referencePoint should not be empty", ^{
            expect(anchorPoint.referencePoint).toNot.beNil;
        });
        
    });
    
    context(@"when getting location name string", ^{
        
        before(^{
            anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationCenter];
        });
        
        it(@"it should give a proper name", ^{
            expect([anchorPoint locationName]).to.equal(@"Center");
        });
        
    });
    
    
    
});

SpecEnd
