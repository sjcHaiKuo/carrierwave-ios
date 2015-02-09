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
    
    beforeEach(^{
        anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationCenter];
    });
    
    afterEach(^{
        anchorPoint = nil;
    });
    
    context(@"when newly created", ^{
        
        it(@"it should have 9 CRVAnchorPointLocation enum elements", ^{
            expect(CRVAnchorPointLocationPointsCount).to.equal(9);
        });
    });
        
    context(@"with center location", ^{
            
        CRVAnchorPointLocation centerLocation = CRVAnchorPointLocationCenter;
            
        it(@"should be initialized with center location", ^{
            expect(anchorPoint.location).to.equal(centerLocation);
        });
            
        it(@"should be not initialized with some other location than center", ^{
            expect(anchorPoint.location).toNot.equal(CRVAnchorPointLocationMiddleRight);
        });
            
        it(@"should give a proper name", ^{
            expect([anchorPoint locationName]).to.equal(@"Center");
        });
            
        it(@"should have a proper adjusts and ratios", ^{
            CRVAnchorPoint *centerAnchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationCenter];
            CRVAnchorPoint *bottomRightAnchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationBottomRight];
            
            expect(anchorPoint).to.crv_beEqualToAnchorPoint(centerAnchorPoint);
            expect(anchorPoint).toNot.crv_beEqualToAnchorPoint(bottomRightAnchorPoint);
        });
    });
    
    context(@"with some other location than center", ^{
            
        CRVAnchorPointLocation otherLocation = CRVAnchorPointLocationTopLeft;
            
        beforeEach(^{
            anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:otherLocation];
        });
            
        it(@"should be initialized with some other location than center", ^{
           expect(anchorPoint.location).to.equal(otherLocation);
        });
            
        it(@"should be not initialized with center location", ^{
            expect(anchorPoint.location).toNot.equal(CRVAnchorPointLocationCenter);
        });
            
        it(@"should give a proper name", ^{
            expect([anchorPoint locationName]).to.equal(@"Top Left");
        });
            
        it(@"should have a proper adjusts and ratios", ^{
            CRVAnchorPoint *topLeftAnchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationTopLeft];
            CRVAnchorPoint *bottomMiddleAnchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationBottomMiddle];
                
            expect(anchorPoint).to.crv_beEqualToAnchorPoint(topLeftAnchorPoint);
            expect(anchorPoint).toNot.crv_beEqualToAnchorPoint(bottomMiddleAnchorPoint);
        });
    });

    describe(@"distance between reference point and touch point", ^{
        
        CGPoint expectedPoint = CGPointMake(25.f, 50.f);
        
        beforeEach(^{
            CGSize size = CGSizeMake(50.f, 100.f);
            [anchorPoint setReferencePointWithSize:size];
        });
        
        it(@"should be calculated properly", ^{
            expect(anchorPoint.referencePoint).to.equal(expectedPoint);
        });
    });
    
    describe(@"calculating distance from reference point to point", ^{
            
        __block CGPoint point;
        __block CGFloat distance;
            
        beforeEach(^{
            point = CGPointMake(20.f, 30.f);
            distance = [anchorPoint distanceFromReferencePointToPoint:point];
        });
            
        it(@"should be calculated properly", ^{
            expect(distance).to.beCloseToWithin(36.f, 0.1f); // exact expected value: 36.05551275...
        });
    });
});

SpecEnd
