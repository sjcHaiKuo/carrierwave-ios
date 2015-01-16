//
//  CRVVideoAssetSpec.m
//  Carrierwave
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVVideoAssetSpec)

describe(@"CRVVideoAsset", ^{
    
    __block CRVVideoAsset *asset = nil;
    
    context(@"when initialized with a local mov file", ^{
        
        beforeEach(^{
            NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"seconds" ofType:@"mov"];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            asset = [[CRVVideoAsset alloc] initWithLocalURL:fileURL];
        });
        
        itShouldBehaveLike(@"asset", ^{
            return @{
                     @"asset": asset,
                     @"extension": @"mov",
                     @"mime": @"video/quicktime",
                     };
        });
        
    });
    
    context(@"when initialized with a local mp4 file", ^{
        
        beforeEach(^{
            NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"seconds" ofType:@"mp4"];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            asset = [[CRVVideoAsset alloc] initWithLocalURL:fileURL];
        });
        
        itShouldBehaveLike(@"asset", ^{
            return @{
                     @"asset": asset,
                     @"extension": @"mp4",
                     @"mime": @"video/mp4",
                     };
        });
        
    });
    
});

SpecEnd
