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

    sharedExamplesFor(@"asset guessing the correct mime type", ^(NSDictionary *data) {

        __block CRVImageAsset *asset = nil;

        beforeEach(^{
            NSString *fileName = data[@"name"], *fileExtension = data[@"extension"];
            NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:fileExtension];
            NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
            asset = [[CRVImageAsset alloc] initWithData:fileData fileName:nil mimeType:nil];
        });

        it(@"should have a data representation", ^{
            expect(asset.data).toNot.beNil();
        });

        it(@"should not have a file name", ^{
            expect(asset.fileName).to.beNil();
        });

        it(@"should have a correct mime type", ^{
            NSString *expectedMimeType = data[@"mime"];
            expect(asset.mimeType).to.equal(expectedMimeType);
        });

    });

    context(@"when initialized with bmp data", ^{

        itShouldBehaveLike(@"asset guessing the correct mime type", @{
            @"name": @"pixel",
            @"extension": @"bmp",
            @"mime": @"image/x-ms-bmp",
        });

    });

    context(@"when initialized with gif data", ^{

        itShouldBehaveLike(@"asset guessing the correct mime type", @{
            @"name": @"pixel",
            @"extension": @"gif",
            @"mime": @"image/gif",
        });

    });

    context(@"when initialized with jpg data", ^{

        itShouldBehaveLike(@"asset guessing the correct mime type", @{
            @"name": @"pixel",
            @"extension": @"jpg",
            @"mime": @"image/jpeg",
        });

    });

    context(@"when initialized with png data", ^{

        itShouldBehaveLike(@"asset guessing the correct mime type", @{
            @"name": @"pixel",
            @"extension": @"png",
            @"mime": @"image/png",
        });

    });

    context(@"when initialized with psd data", ^{

        itShouldBehaveLike(@"asset guessing the correct mime type", @{
            @"name": @"pixel",
            @"extension": @"psd",
            @"mime": @"image/psd",
        });

    });

    context(@"when initialized with tiff data", ^{

        itShouldBehaveLike(@"asset guessing the correct mime type", @{
            @"name": @"pixel",
            @"extension": @"tiff",
            @"mime": @"image/tiff",
        });

    });

    context(@"when initialized with bmp data", ^{

        itShouldBehaveLike(@"asset guessing the correct mime type", @{
            @"name": @"pixel",
            @"extension": @"webp",
            @"mime": @"image/webp",
        });

    });

});

SpecEnd
