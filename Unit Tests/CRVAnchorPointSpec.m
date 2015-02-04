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
        
        beforeEach(^{
            anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationCenter];
        });
        
        it(@"it should have 9 CRVAnchorPointLocation enum elements", ^{
            expect(CRVAnchorPointLocationPointsCount).to.equal(9);
        });
        
        context(@"with center location", ^{
            
            CRVAnchorPointLocation centerLocation = CRVAnchorPointLocationCenter;
            
            beforeEach(^{
                anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:centerLocation];
            });
            
            it(@"it should be initialized with center location", ^{
                expect(anchorPoint.location).to.equal(centerLocation);
            });
            
            it(@"it should be not initialized with some other location than center", ^{
                expect(anchorPoint.location).toNot.equal(CRVAnchorPointLocationMiddleRight);
            });
            
            it(@"it should give a proper name", ^{
                expect([anchorPoint locationName]).to.equal(@"Center");
            });
            
            describe(@"using reference point", ^{
                
                CGPoint expectedPoint = CGPointMake(25.f, 50.f);
                
                before(^{
                    CGSize size = CGSizeMake(50.f, 100.f);
                    [anchorPoint setReferencePointWithSize:size];
                });
                
                it(@"it should have a proper value", ^{
                    expect(anchorPoint.referencePoint).to.equal(expectedPoint);
                });
                
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
            
            it(@"it should give a proper name", ^{
                expect([anchorPoint locationName]).to.equal(@"Bottom Right");
            });
            
            describe(@"using reference point", ^{
                
                CGPoint expectedPoint = CGPointMake(30.f, 140.f);
                
                before(^{
                    CGSize size = CGSizeMake(30.f, 140.f);
                    [anchorPoint setReferencePointWithSize:size];
                });
                
                it(@"it should have a proper value", ^{
                    expect(anchorPoint.referencePoint).to.equal(expectedPoint);
                });
                
            });
            
        });
        
        describe(@"distanceFromReferencePointToPoint", ^{
            
            __block CGPoint point;
            __block CGFloat distance;
            
            before(^{
                point = CGPointMake(20.f, 30.f);
                distance = [anchorPoint distanceFromReferencePointToPoint:point];
            });
            
            it(@"should give a proper value", ^{
                expect(distance).to.beCloseToWithin(36.f, 0.1f); // exact expected value: 36.05551275...
            });
            
        });
        
    });
    
});

SpecEnd
