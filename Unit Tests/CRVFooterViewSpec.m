//
//  CRVFooterViewSpec.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 25.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVFooterViewSpec)

describe(@"CRVFooterView", ^{
    
    __block CRVFooterView *sut;
    
    beforeEach(^{
        sut = [[CRVFooterView alloc] init];
    });
    
    afterEach(^{
        sut = nil;
    });
    
    context(@"when newly created", ^{
        
        it(@"should not be nil", ^{
            expect(sut).toNot.beNil();
        });
        
        it(@"should inherits from CRVHeaderFooterView class", ^{
            expect(sut).to.beKindOf([CRVHeaderFooterView class]);
        });
        
    });
    
    describe(@"when cancel", ^{
        
        itShouldBehaveLike(@"button did tap", ^{
            return @{@"view": sut,
                     @"title": @"Cancel",
                     @"notificationName": @"NGRImageEditViewControllerWillCancelEditingNotification"};
        });
    });
    
    describe(@"when ratio", ^{
        
        itShouldBehaveLike(@"button did tap", ^{
            return @{@"view": sut,
                     @"title": @"Ratio",
                     @"notificationName": @"NGRImageEditViewControllerWillShowRatioAlertControllerNotification"};
        });
    });
    
    describe(@"when done", ^{
        
        itShouldBehaveLike(@"button did tap", ^{
            return @{@"view": sut,
                     @"title": @"Done",
                     @"notificationName": @"NGRImageEditViewControllerWillFinishEditingWithImageAssetNotification"};
        });
    });
    
    describe(@"when reset button did tap", ^{
        
        itShouldBehaveLike(@"button did tap", ^{
            return @{@"view": sut,
                     @"title": @"Reset",
                     @"notificationName": @"NGRTransformViewControllerWillResetTransformationNotification"};
        });
    });
});

SpecEnd
