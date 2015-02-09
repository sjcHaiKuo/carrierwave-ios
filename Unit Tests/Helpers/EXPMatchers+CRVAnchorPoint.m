//
//  EXPMatchers+CRVAnchorPoint.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "EXPMatchers+CRVAnchorPoint.h"

EXPMatcherImplementationBegin(crv_beEqualToAnchorPoint, (CRVAnchorPoint *expectedAnchorPoint)) {
    
    BOOL actualIsAnAnchorPoint = [actual isKindOfClass:[CRVAnchorPoint class]];
    CRVAnchorPoint *actualAnchorPoint = (CRVAnchorPoint *)actual;
    
    prerequisite(^BOOL {
        return actualIsAnAnchorPoint;
    });
    
    match(^BOOL {
        if (actualAnchorPoint.adjustsX == expectedAnchorPoint.adjustsX &&
            actualAnchorPoint.adjustsY == expectedAnchorPoint.adjustsY &&
            actualAnchorPoint.adjustsW == expectedAnchorPoint.adjustsW &&
            actualAnchorPoint.adjustsH == expectedAnchorPoint.adjustsH &&
            actualAnchorPoint.ratioX1 == expectedAnchorPoint.ratioX1 &&
            actualAnchorPoint.ratioX2 == expectedAnchorPoint.ratioX2 &&
            actualAnchorPoint.ratioY1 == expectedAnchorPoint.ratioY1 &&
            actualAnchorPoint.ratioY2 == expectedAnchorPoint.ratioY2 &&
            actualAnchorPoint.ratioW == expectedAnchorPoint.ratioW &&
            actualAnchorPoint.ratioH == expectedAnchorPoint.ratioH)
            return true;
                else return false;
    });
    
    failureMessageForTo(^NSString * {
        NSString *expectedDescription = @"";
        NSString *actualDescription = @"";
        
        if (!actualIsAnAnchorPoint) {
            expectedDescription = [NSString stringWithFormat:@"an instance of %@", [CRVAnchorPoint class]];
            actualDescription = [NSString stringWithFormat:@"an instance of %@", [actual class]];

            return [NSString stringWithFormat:@"expected: %@, got: %@", expectedDescription, actualDescription];
        } else {
            return @"Anchor points are not equal.";
        }
    });
    
    failureMessageForNotTo(^NSString * {
        NSString *expectedDescription = @"";
        NSString *actualDescription = @"";
        
        if (!actualIsAnAnchorPoint) {
            expectedDescription = [NSString stringWithFormat:@"an instance of %@", [CRVAnchorPoint class]];
            actualDescription = [NSString stringWithFormat:@"an instance of %@", [actual class]];

            return [NSString stringWithFormat:@"expected: %@, got: %@", expectedDescription, actualDescription];
        } else {
            return @"Anchor points are not equal.";
        }
    });
    
} EXPMatcherImplementationEnd
