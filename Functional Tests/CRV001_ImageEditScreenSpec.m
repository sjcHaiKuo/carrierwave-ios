//
//  CRV001_ImageEditScreenSpec.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 04.03.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRV001_ImageEditScreenSpec)

describe(@"Image edit screen", ^{
    
    __block UIImage *initialImage = nil;
    
    beforeAll(^{
        initialImage = ((UIImageView *)[tester waitForViewWithAccessibilityLabel:@"Cell ImageView"]).image;
    });
    
    beforeEach(^{
        [tester crv_tapCropButton];
    });
    
    context(@"when cancelling", ^{
        
        beforeEach(^{
            [tester crv_tapCancelButton];
        });
        
        it(@"cropped image should be same as original image.", ^{
            UIImage *image = ((UIImageView *)[tester waitForViewWithAccessibilityLabel:@"Cell ImageView"]).image;
            expect(image.size).to.equal(initialImage.size);
            expect(image).to.equal(initialImage);
        });
    });
    
    context(@"when cropping", ^{
        
        beforeEach(^{
            [tester crv_tapDoneButton];
        });
        
        it(@"cropped image should be different than original image.", ^{
            UIImage *image = ((UIImageView *)[tester waitForViewWithAccessibilityLabel:@"Cell ImageView"]).image;
            expect(image.size).toNot.equal(initialImage.size);
            expect(image).toNot.equal(initialImage);
        });
    });
    
    context(@"when moving crop view", ^{
        
        __block CGRect initialFrame;
        
        beforeEach(^{
            initialFrame = [tester waitForViewWithAccessibilityLabel:@"Crop Image View"].frame;
            [tester crv_moveCropImageView];
        });
        
        afterEach(^{
            [tester crv_tapCancelButton];
        });
        
        it(@"and tapping reset button, should back to initial position.", ^{
            [tester crv_tapResetButton];
            CGRect frame = [tester waitForViewWithAccessibilityLabel:@"Crop Image View"].frame;
            expect(initialFrame).to.equal(frame);
        });
    });
    
    context(@"when double tapping in crop view", ^{
        
        __block NGRScalableView *view;
        
        beforeEach(^{
            view = (NGRScalableView *)[tester waitForViewWithAccessibilityLabel:@"Scalable View"];
            [tester crv_doubleTapInCropView];
        });
        
        afterEach(^{
            [tester crv_tapCancelButton];
        });
        
        it(@"should be inactive.", ^{
            expect(view.isActive).to.beFalsy();
        });
    });
    
    context(@"when changing ratio", ^{
        
        __block CGSize initialSize;
        
        beforeEach(^{
            initialSize = [tester waitForViewWithAccessibilityLabel:@"Scalable View"].frame.size;
            
            [tester crv_tapRatioButton];
            [tester waitAndTapViewWithAccessibilityLabel:@"2:1"];
        });
        
        afterEach(^{
            [tester crv_tapCancelButton];
        });
        
        it(@"crop view should scale.", ^{
            CGSize size = [tester waitForViewWithAccessibilityLabel:@"Scalable View"].frame.size;
            expect(size).toNot.equal(initialSize);
        });
    });
});

SpecEnd
