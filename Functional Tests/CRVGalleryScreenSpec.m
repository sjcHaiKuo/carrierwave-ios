//
//  CRVRootScreen.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 03.03.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVGalleryScreenSpec)

describe(@"gallery screen", ^{
    
    __block id<OHHTTPStubsDescriptor> stub = nil;
    
    BOOL (^existButtonsWithLabels)(NSString *, NSString *) = ^BOOL (NSString *label_1, NSString *label_2) {
        return [tester waitForViewWithAccessibilityLabel:label_1] != nil && [tester waitForViewWithAccessibilityLabel:label_2] != nil;
    };
    
    context(@"tapping upload button", ^{
        
        beforeAll(^{
            stub = [OHHTTPStubs crv_stubUploadRequest];
        });
        
        beforeEach(^{
            [tester crv_tapUploadButton];
        });
        
        afterAll(^{
            [OHHTTPStubs removeStub:stub];
        });
        
        it(@"when completed should show download and delete button.", ^{
            XCTAssertTrue(existButtonsWithLabels(@"Download", @"Delete"), @"Download and/or delete button doesn't not exist!");
        });
    });
    
    context(@"tapping download button", ^{
        
        beforeAll(^{
            stub = [OHHTTPStubs crv_stubDownloadRequestAndTakeANap];
        });
        
        beforeEach(^{
            [tester crv_tapDownloadButton];
        });
        
        afterAll(^{
            [OHHTTPStubs removeStub:stub];
        });
        
        it(@"when completed shouldn't change buttons.", ^{
            XCTAssertTrue(existButtonsWithLabels(@"Download", @"Delete"), @"Download and/or delete button doesn't not exist!");
        });
        
        it(@"when downloading, show cancel and pause buttons.", ^{
            XCTAssertTrue(existButtonsWithLabels(@"Cancel", @"Pause"), @"Cancel and/or pause button doesn't not exist!");
        });
    });
    
    context(@"tapping delete button", ^{
        
        beforeAll(^{
            stub = [OHHTTPStubs crv_stubDeletionRequest];
        });
        
        beforeEach(^{
            [tester crv_tapDeleteButton];
        });
        
        afterAll(^{
            [OHHTTPStubs removeStub:stub];
        });
        
        it(@"after deleting, should show crop and upload buttons.", ^{
            XCTAssertTrue(existButtonsWithLabels(@"Crop", @"Upload"), @"Download and/or delete button doesn't not exist!");
        });
    });
    
    it(@"when tapping camera bar button, should show and hide photo album", ^{
        [tester crv_openPhotoAlbum];
        [tester crv_closePhotoAlbum];
    });
});

SpecEnd


