//
//  EXPMatchers+CRVAnchorPoint.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "EXPMatchers+CRVAnchorPoint.h"

@interface CRVTestAnchorPoint : CRVAnchorPoint

// Mock propperties for test purposes
@property (assign, nonatomic, readonly) CGFloat multiplierX;
@property (assign, nonatomic, readonly) CGFloat multiplierY;

@end

typedef BOOL (^CRVVerifyFactors)(CGFloat adjustsX, CGFloat adjustsY, CGFloat adjustsH, CGFloat adjustsW, CGFloat multiplierX, CGFloat multiplierY, CGFloat ratioX1, CGFloat ratioX2, CGFloat ratioY1, CGFloat ratioY2, CGFloat ratioW, CGFloat ratioH);

static CGFloat givenFactor;
static CGFloat expectedFactor;
static NSString *factorName;

EXPMatcherImplementationBegin(crv_hasProperFactors, (void)) {

    BOOL actualIsAnAnchorPoint = [actual isKindOfClass:[CRVAnchorPoint class]];
    CRVTestAnchorPoint *anchor = (CRVTestAnchorPoint *)actual;
    
    prerequisite(^BOOL {
        return actualIsAnAnchorPoint;
    });
    
    match(^BOOL {
        
        CRVVerifyFactors verifyFactors = ^BOOL(CGFloat adjustsX, CGFloat adjustsY, CGFloat adjustsH, CGFloat adjustsW, CGFloat multiplierX, CGFloat multiplierY, CGFloat ratioX1, CGFloat ratioX2, CGFloat ratioY1, CGFloat ratioY2, CGFloat ratioW, CGFloat ratioH) {
            
            BOOL success = YES;
            
            if (anchor.adjustsX != adjustsX) {
                givenFactor = anchor.adjustsX; expectedFactor = adjustsX; factorName = @"adjustX"; success = NO;
            } else if (anchor.adjustsY != adjustsY) {
                givenFactor = anchor.adjustsY; expectedFactor = adjustsY; factorName = @"adjustsY"; success = NO;
            } else if (anchor.adjustsH != adjustsH) {
                givenFactor = anchor.adjustsH; expectedFactor = adjustsH; factorName = @"adjustsH"; success = NO;
            } else if (anchor.adjustsW != adjustsW) {
                givenFactor = anchor.adjustsW; expectedFactor = adjustsW; factorName = @"adjustsW"; success = NO;
            } else if (anchor.multiplierX != multiplierX) {
                givenFactor = anchor.multiplierX; expectedFactor = multiplierX; factorName = @"multiplierX"; success = NO;
            } else if (anchor.multiplierY != multiplierY) {
                givenFactor = anchor.multiplierY; expectedFactor = multiplierY; factorName = @"multiplierY"; success = NO;
            } else if (anchor.ratioX1 != ratioX1) {
                givenFactor = anchor.ratioX1; expectedFactor = ratioX1; factorName = @"ratioX1"; success = NO;
            } else if (anchor.ratioX2 != ratioX2) {
                givenFactor = anchor.ratioX2; expectedFactor = ratioX2; factorName = @"ratioX2"; success = NO;
            } else if (anchor.ratioY1 != ratioY1) {
                givenFactor = anchor.ratioY1; expectedFactor = ratioY1; factorName = @"ratioY1"; success = NO;
            } else if (anchor.ratioY2 != ratioY2) {
                givenFactor = anchor.ratioY2; expectedFactor = ratioY2; factorName = @"ratioY2"; success = NO;
            } else if (anchor.ratioW != ratioW) {
                givenFactor = anchor.ratioW; expectedFactor = ratioW; factorName = @"ratioW"; success = NO;
            } else if (anchor.ratioH != ratioH) {
                givenFactor = anchor.ratioH; expectedFactor = ratioH; factorName = @"ratioH"; success = NO;
            }
            return success;
        };
        
        switch (anchor.location) {
                
            case CRVAnchorPointLocationTopLeft: {
                return verifyFactors(1.f, 1.f, -1.f, 1.f, 0.f, 0.f, 0.f, 0.f, -1.f, 0.f, 0.f, 1.f);
            }
            case CRVAnchorPointLocationMiddleLeft: {
                return verifyFactors(1.f, 0.f, 0.f, 1.f, 0.f, .5f, -1.f, 0.f, -.5f, 0.f, 0.f, 1.f);
            }
            case CRVAnchorPointLocationBottomLeft: {
                return verifyFactors(1.f, 0.f, 1.f, 1.f, 0.f, 1.f, 0.f, 0.f, 0.f, 0.f, 0.f, 1.f);
            }
            case CRVAnchorPointLocationTopRight: {
                return verifyFactors(0.f, 1.f, -1.f, -1.f, 1.f, 0.f, 0.f, 0.f, -1.f, 0.f, 0.f, 1.f);
            }
            case CRVAnchorPointLocationMiddleRight: {
                return verifyFactors(0.f, 0.f, 0.f, -1.f, 1.f, .5f, 0.f, 0.f, -.5f, 0.f, 0.f, 1.f);
            }
            case CRVAnchorPointLocationBottomRight: {
                return verifyFactors(0.f, 0.f, 1.f, -1.f, 1.f, 1.f, 0.f, 0.f, 0.f, 0.f, 0.f, 1.f);
            }
            case CRVAnchorPointLocationTopMiddle: {
                return verifyFactors(0.f, 1.f, -1.f, 0.f, .5f, 0.f, 0.f, -.5f, 0.f, -1.f, 1.f, 0.f);
            }
            case CRVAnchorPointLocationBottomMiddle: {
                return verifyFactors(0.f, 0.f, 1.f, 0.f, .5f, 1.f, 0.f, -.5f, 0.f, 0.f, 1.f, 0.f);
            }
            case CRVAnchorPointLocationCenter:
            case CRVAnchorPointLocationPointsCount:
            default: {
                return verifyFactors(0.f, 0.f, 0.f, 0.f, .5f, .5f, 0.f, 0.f, 0.f, 0.f, 0.f, 0.f);
            }
        }
    });
    
    failureMessageForTo(^NSString * {
        NSString *expectedDescription = @"";
        NSString *actualDescription = @"";
        
        if (!actualIsAnAnchorPoint) {
            expectedDescription = [NSString stringWithFormat:@"an instance of %@", [CRVAnchorPoint class]];
            actualDescription = [NSString stringWithFormat:@"an instance of %@", [actual class]];

            return [NSString stringWithFormat:@"expected: %@, got: %@", expectedDescription, actualDescription];
        } else {
            return [NSString stringWithFormat:@"expected %@: %.2f, got: %.2f", factorName, expectedFactor, givenFactor];
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
            return [NSString stringWithFormat:@"expected %@: %.2f, got: %.2f", factorName, expectedFactor, givenFactor];
        }
    });
    
} EXPMatcherImplementationEnd
