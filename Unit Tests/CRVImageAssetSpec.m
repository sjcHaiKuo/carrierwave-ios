//
//  CRVImageAssetSpec.m
//
//  Copyright 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVImageAsset)

describe(@"CRVImageAsset", ^{

    __block CRVImageAsset *asset = nil;

    context(@"when initialized with image", ^{

        beforeEach(^{
            UIImage *image = [UIImage crv_composeImageWithSize:CGSizeMake(5, 5) color:[UIColor redColor]];
            asset = [[CRVImageAsset alloc] initWithImage:image fileName:nil];
        });

        it(@"should have a data representation", ^{
            expect(asset.data).toNot.beNil();
        });

        it(@"should not have a file name", ^{
            expect(asset.fileName).to.beNil();
        });

        it(@"should have a png type", ^{
            expect(asset.mimeType).to.equal(@"image/png");
        });

    });

    context(@"when initialized with local url", ^{

        __block NSError *error = nil;

        beforeEach(^{
            NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"pixel" ofType:@"gif"];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            asset = [[CRVImageAsset alloc] initWithLocalURL:fileURL error:&error];
        });

        specify(@"there should be no error", ^{
            expect(error).to.beNil();
        });

        it(@"should have a data representation", ^{
            expect(asset.data).toNot.beNil();
        });

        it(@"should have a correct file name", ^{
            expect(asset.fileName).to.equal(@"pixel.gif");
        });

        it(@"should have a correct mime type", ^{
            expect(asset.mimeType).to.equal(@"image/gif");
        });

    });

});

SpecEnd
