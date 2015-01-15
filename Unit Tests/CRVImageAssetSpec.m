//
//  CRVImageAssetSpec.m
//
//  Copyright 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVImageAsset)

describe(@"CRVImageAsset", ^{

    __block CRVImageAsset *asset = nil;

    context(@"when initialized with an image", ^{

        beforeEach(^{
            UIImage *image = [UIImage crv_composeImageWithSize:CGSizeMake(5, 5) color:[UIColor redColor]];
            asset = [[CRVImageAsset alloc] initWithImage:image];
        });

        itShouldBehaveLike(@"asset", ^{
            return @{
                @"asset": asset,
                @"extension": @"png",
                @"mime": @"image/png",
            };
        });

    });

    context(@"when initialized with a local gif file", ^{

        beforeEach(^{
            NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"pixel" ofType:@"gif"];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            asset = [[CRVImageAsset alloc] initWithLocalURL:fileURL];
        });

        itShouldBehaveLike(@"asset", ^{
            return @{
                @"asset": asset,
                @"extension": @"gif",
                @"mime": @"image/gif",
            };
        });

    });

    context(@"when initialized with a local jpg file", ^{

        beforeEach(^{
            NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"pixel" ofType:@"jpg"];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            asset = [[CRVImageAsset alloc] initWithLocalURL:fileURL];
        });

        itShouldBehaveLike(@"asset", ^{
            return @{
                @"asset": asset,
                @"extension": @"jpeg",
                @"mime": @"image/jpeg",
            };
        });

    });

    context(@"when initialized with a local tiff file", ^{

        beforeEach(^{
            NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"pixel" ofType:@"tiff"];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            asset = [[CRVImageAsset alloc] initWithLocalURL:fileURL];
        });

        itShouldBehaveLike(@"asset", ^{
            return @{
                @"asset": asset,
                @"extension": @"tiff",
                @"mime": @"image/tiff",
            };
        });

    });

    context(@"when initialized with a local png file", ^{

        beforeEach(^{
            NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"pixel" ofType:@"png"];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            asset = [[CRVImageAsset alloc] initWithLocalURL:fileURL];
        });

        itShouldBehaveLike(@"asset", ^{
            return @{
                @"asset": asset,
                @"extension": @"png",
                @"mime": @"image/png",
            };
        });

    });

    describe(@"compression", ^{

        __block CRVImageAsset *compressedAsset = nil;

        beforeEach(^{
            UIImage *image = [UIImage crv_composeImageWithSize:CGSizeMake(500, 500) color:[UIColor greenColor]];
            asset = [[CRVImageAsset alloc] initWithImage:image];
            compressedAsset = [asset compressedImageAssetWithQuality:(CGFloat)0.1];
        });

        specify(@"compressed asset should not be nil", ^{
            expect(compressedAsset).toNot.beNil();
        });

        it(@"should decrease the image weight", ^{
            expect(compressedAsset.dataLength).to.beLessThan(asset.dataLength);
        });

    });

});

SpecEnd
