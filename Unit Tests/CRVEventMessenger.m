//
//  CRVEventMessenger.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 26.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVEventMessengerSpec)

describe(@"CRVEventMessenger", ^{
    
    __block CRVEventMessenger *sut;
    
    context(@"when initialized", ^{
        
        beforeEach(^{
            sut = [[CRVEventMessenger alloc] init];
        });
        
        afterEach(^{
            sut = nil;
        });
        
        it(@"should not be nil", ^{
            expect(sut).toNot.beNil();
        });
        
        it(@"should post done notifiction", ^{
            expect(^{
                [sut postDoneMessage];
            }).will.notify(@"NGRImageEditViewControllerWillFinishEditingWithImageAssetNotification");
        });
        
        it(@"should post cancel notifiction", ^{
            expect(^{
                [sut postCancelMessage];
            }).will.notify(@"NGRImageEditViewControllerWillCancelEditingNotification");
        });
        
        it(@"should post ratio notifiction", ^{
            expect(^{
                [sut postShowRatioSheetMessage];
            }).will.notify(@"NGRImageEditViewControllerWillShowRatioAlertControllerNotification");
        });
        
        it(@"should post reset notifiction", ^{
            expect(^{
                [sut postResetTransformationMessage];
            }).will.notify(@"CRVTransformViewControllerWillResetTransformationNotification");
        });
    });
});

SpecEnd
