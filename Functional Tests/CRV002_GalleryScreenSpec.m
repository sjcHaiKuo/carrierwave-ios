//
//  CRV002_GalleryScreenSpec.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 03.03.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRV002_GalleryScreenSpec)

describe(@"Gallery screen", ^{
    
    __block id<OHHTTPStubsDescriptor> stub = nil;

    BOOL (^existButtonsWithLabels)(NSString *, NSString *) = ^BOOL (NSString *label_1, NSString *label_2) {
        return [tester waitForViewWithAccessibilityLabel:label_1] != nil && [tester waitForViewWithAccessibilityLabel:label_2] != nil;
    };

    context(@"when uploading", ^{
        
        beforeAll(^{
            stub = [OHHTTPStubs crv_stubUploadRequest];
        });
        
        beforeEach(^{
            [tester crv_tapUploadButton];
        });
        
        afterAll(^{
            [OHHTTPStubs removeStub:stub];
        });
        
        it(@"on completion, should show download and delete button.", ^{
            XCTAssertTrue(existButtonsWithLabels(@"Download", @"Delete"), @"Download and/or delete button doesn't not exist!");
        });
    });
    
    context(@"when downloading", ^{
        
        beforeAll(^{
            stub = [OHHTTPStubs crv_stubDownloadRequestAndResponseAfter:4];
        });
        
        afterAll(^{
            [OHHTTPStubs removeStub:stub];
        });
        
        context(@"tapping download button", ^{
            
            beforeAll(^{
                [tester crv_tapDownloadButton];
            });
            
            it(@"should show pause and cancel buttons.", ^{
                XCTAssertTrue(existButtonsWithLabels(@"Pause", @"Cancel"), @"Download and/or delete button doesn't not exist!");
            });
            
            it(@"when completed, should show download and delete buttons.", ^{
                XCTAssertTrue(existButtonsWithLabels(@"Download", @"Delete"), @"Download and/or delete button doesn't not exist!");
            });
        });
        
        context(@"tapping download button", ^{
            
            beforeAll(^{
                [tester crv_tapDownloadButton];
            });
            
            it(@"should show pause and cancel buttons.", ^{
                XCTAssertTrue(existButtonsWithLabels(@"Pause", @"Cancel"), @"Download and/or delete button doesn't not exist!");
            });
        });
        
        context(@"tapping pause button", ^{
            
            beforeEach(^{
                [tester crv_tapPauseButton];
            });
            
            it(@"should show resume and cancel buttons.", ^{
                XCTAssertTrue(existButtonsWithLabels(@"Resume", @"Cancel"), @"Cancel and/or pause button doesn't not exist!");
            });
        });

        context(@"tapping resume button", ^{
            
            beforeAll(^{
                [tester crv_tapResumeButton];
            });
            
            it(@"should show cancel and pause buttons.", ^{
                XCTAssertTrue(existButtonsWithLabels(@"Pause", @"Cancel"), @"Cancel and/or pause button doesn't not exist!");
            });
            
        });

        context(@"tapping cancel button", ^{
            
            beforeAll(^{
                [tester crv_tapCancelButton];
            });
            
            it(@"should show download and delete buttons.", ^{
                XCTAssertTrue(existButtonsWithLabels(@"Download", @"Delete"), @"Cancel and/or pause button doesn't not exist!");
            });
            
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
    
    context(@"when tapping camera bar button", ^{
        
        beforeEach(^{
            [tester crv_openPhotoAlbum];
        });
        
        context(@"and closing photo album", ^{
            
            beforeEach(^{
                [tester crv_closePhotoAlbum];
            });
            
            it(@"should collection view have 1 image", ^{
                UICollectionView *collectionView = (UICollectionView *)[tester waitForViewWithAccessibilityLabel:@"Collection View"];
                expect([collectionView numberOfItemsInSection:0]).to.equal(1);
            });
        });
        
        context(@"and choosing a photo", ^{
            
            beforeEach(^{
                [tester choosePhotoInAlbum:@"Camera Roll" atRow:1 column:0];
            });
            
            it(@"should collection view have 2 images", ^{
                UICollectionView *collectionView = (UICollectionView *)[tester waitForViewWithAccessibilityLabel:@"Collection View"];
                expect([collectionView numberOfItemsInSection:0]).to.equal(2);
            });
        });
    });
});

SpecEnd


