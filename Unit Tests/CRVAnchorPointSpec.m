//
//  CRVAnchorPointSpec.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 29.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//


NSString *const CRVAnchorPointKey = @"CRVAnchorPointKey";
NSString *const CRVAnchorPointLocationKey = @"CRVAnchorPointLocationKey";
NSString *const CRVAnchorPointLocationNameKey = @"CRVAnchorPointLocationNameKey";

SharedExamplesBegin(CRVAnchorPointSharedExamples)

sharedExamplesFor(@"CRVAnchorPoint", ^(NSDictionary *data) {
    
    __block CRVAnchorPoint *anchorPoint = nil;
    __block NSString *anchorPointName = nil;
    __block CRVAnchorPointLocation location;
    
    beforeEach(^{
        anchorPointName = data[CRVAnchorPointLocationNameKey];
        anchorPoint = data[CRVAnchorPointKey];
        location = [data[CRVAnchorPointLocationKey] integerValue];
    });
    
    it(@"should not be nil", ^{
        expect(anchorPoint).toNot.beNil();
    });
        
    it([NSString stringWithFormat:@"should be initialized with %@ location", [anchorPoint locationName]], ^{
        expect(anchorPoint.location).to.equal(location);
    });
    
    it([NSString stringWithFormat:@"should have a %@ name", [anchorPoint locationName]], ^{
        expect([anchorPoint locationName]).to.equal(anchorPointName);
    });
    
    it(@"should have a proper adjusts and ratios", ^{
        expect(anchorPoint).to.crv_hasProperFactors();
    });
});

SharedExamplesEnd

SpecBegin(CRVAnchorPointSpec)

describe(@"CRVAnchorPointSpec", ^{
    
    __block CRVAnchorPoint *anchorPoint = nil;
    
    it(@"should have 9 CRVAnchorPointLocation enum elements", ^{
        expect(CRVAnchorPointLocationPointsCount).to.equal(9);
    });
    
    context(@"when initialized with a center", ^{
  
        beforeEach(^{
            anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationCenter];
        });
        
        itShouldBehaveLike(@"CRVAnchorPoint", ^{
            return @{CRVAnchorPointKey : anchorPoint,
                     CRVAnchorPointLocationKey : @(CRVAnchorPointLocationCenter),
                     CRVAnchorPointLocationNameKey : @"Center"};
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
            });
            
            it(@"should be calculated properly", ^{
                distance = [anchorPoint distanceFromReferencePointToPoint:point];
                expect(distance).to.beCloseToWithin(36.f, 0.1f); // exact expected value: 36.05551275...
            });
        });
    });
    
    context(@"when initialized with a top left", ^{
        
        beforeEach(^{
            anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationTopLeft];
        });
        
        itShouldBehaveLike(@"CRVAnchorPoint", ^{
            return @{CRVAnchorPointKey : anchorPoint,
                     CRVAnchorPointLocationKey : @(CRVAnchorPointLocationTopLeft),
                     CRVAnchorPointLocationNameKey : @"Top Left"};
        });
    });
    
    context(@"when initialized with a middle left", ^{
        
        beforeEach(^{
            anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationMiddleLeft];
        });
        
        itShouldBehaveLike(@"CRVAnchorPoint", ^{
            return @{CRVAnchorPointKey : anchorPoint,
                     CRVAnchorPointLocationKey : @(CRVAnchorPointLocationMiddleLeft),
                     CRVAnchorPointLocationNameKey : @"Middle Left"};
        });
    });
    
    context(@"when initialized with a bottom left", ^{
        
        beforeEach(^{
            anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationBottomLeft];
        });
        
        itShouldBehaveLike(@"CRVAnchorPoint", ^{
            return @{CRVAnchorPointKey : anchorPoint,
                     CRVAnchorPointLocationKey : @(CRVAnchorPointLocationBottomLeft),
                     CRVAnchorPointLocationNameKey : @"Bottom Left"};
        });
    });
    
    context(@"when initialized with a top right", ^{

        beforeEach(^{
            anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationTopRight];
        });
        
        itShouldBehaveLike(@"CRVAnchorPoint", ^{
            return @{CRVAnchorPointKey : anchorPoint,
                     CRVAnchorPointLocationKey : @(CRVAnchorPointLocationTopRight),
                     CRVAnchorPointLocationNameKey : @"Top Right"};
        });
    });
    
    context(@"when initialized with a middle right", ^{
        
        beforeEach(^{
            anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationMiddleRight];
        });
        
        itShouldBehaveLike(@"CRVAnchorPoint", ^{
            return @{CRVAnchorPointKey : anchorPoint,
                     CRVAnchorPointLocationKey : @(CRVAnchorPointLocationMiddleRight),
                     CRVAnchorPointLocationNameKey : @"Middle Right"};
        });
    });
    
    context(@"when initialized with a bottom right", ^{
        
        beforeEach(^{
            anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationBottomRight];
        });
        
        itShouldBehaveLike(@"CRVAnchorPoint", ^{
            return @{CRVAnchorPointKey : anchorPoint,
                     CRVAnchorPointLocationKey : @(CRVAnchorPointLocationBottomRight),
                     CRVAnchorPointLocationNameKey : @"Bottom Right"};
        });
    });
    
    context(@"when initialized with a top middle", ^{

        beforeEach(^{
            anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationTopMiddle];
        });
        
        itShouldBehaveLike(@"CRVAnchorPoint", ^{
            return @{CRVAnchorPointKey : anchorPoint,
                     CRVAnchorPointLocationKey : @(CRVAnchorPointLocationTopMiddle),
                     CRVAnchorPointLocationNameKey : @"Top Middle"};
        });
    });
    
    context(@"when initialized with a bottom middle", ^{
        
        beforeEach(^{
            anchorPoint = [[CRVAnchorPoint alloc] initWithLocation:CRVAnchorPointLocationBottomMiddle];
        });
        
        itShouldBehaveLike(@"CRVAnchorPoint", ^{
            return @{CRVAnchorPointKey : anchorPoint,
                     CRVAnchorPointLocationKey : @(CRVAnchorPointLocationBottomMiddle),
                     CRVAnchorPointLocationNameKey : @"Bottom Middle"};
        });
    });
});

SpecEnd
