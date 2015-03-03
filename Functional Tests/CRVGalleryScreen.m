//
//  CRVRootScreen.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 03.03.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVGalleryScreen)

describe(@"gallery screen", ^{
    
    describe(@"left button", ^{
        
        it(@"should be visible", ^{
            [tester waitForViewWithAccessibilityLabel:@"Left Button"];
        });
        
    });
    
});

SpecEnd
