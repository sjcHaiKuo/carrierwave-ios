//
//  CRVSettingsMessenger.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 26.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVSettingsMessengerSpec)

describe(@"CRVSettingsMessenger", ^{
    
    __block CRVSettingsMessenger *sut;
    
    context(@"when initialized", ^{
        
        beforeEach(^{
            sut = [[CRVSettingsMessenger alloc] init];
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
            }).will.notify(@"CRVImageEditViewControllerWillFinishEditingWithImageAssetNotification");
        });
        
        it(@"should post cancel notifiction", ^{
            expect(^{
                [sut postCancelMessage];
            }).will.notify(@"CRVImageEditViewControllerWillCancelEditingNotification");
        });
        
        it(@"should post ratio notifiction", ^{
            expect(^{
                [sut postShowRatioSheetMessage];
            }).will.notify(@"CRVImageEditViewControllerWillShowRatioAlertControllerNotification");
        });
        
        it(@"should post reset notifiction", ^{
            expect(^{
                [sut postResetTransformationMessage];
            }).will.notify(@"CRVTransformViewControllerWillResetTransformationNotification");
        });
    });
});

SpecEnd
