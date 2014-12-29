//
//  CRVAssetTypeBehavior.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SharedExamplesBegin(CRVAssetTypeBehavior)

sharedExamplesFor(@"asset", ^(NSDictionary *data) {

    __block id<CRVAssetType> asset = nil;

    beforeEach(^{
        asset = data[@"asset"];
    });

    it(@"should have a data representation", ^{
        expect(asset.data).toNot.beNil();
    });

    it(@"should have a correct file extension", ^{
        expect(asset).to.crv_haveFileExtensionOf(data[@"extension"]);
    });

    it(@"should have a correct mime type", ^{
        expect(asset).to.crv_haveMimeTypeOf(data[@"mime"]);
    });

});

SharedExamplesEnd
