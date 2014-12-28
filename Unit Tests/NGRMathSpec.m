//
//  NGRMathSpec.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(NGRMath)

describe(@"math", ^{

    sharedExamplesFor(@"subtraction", ^(NSDictionary *data) {

        __block int a = 0, b = 0;

        beforeEach(^{
            a = ((NSNumber *)(data[@"a"])).intValue;
            b = ((NSNumber *)(data[@"b"])).intValue;
        });

        it(@"is not commutative", ^{
            expect(a - b).toNot.equal(b - a);
        });

    });

    __block int a = 0, b = 0;

    beforeEach(^{
        a = arc4random_uniform(32) + 1;
        b = a + arc4random_uniform(32) + 1;
    });

    specify(@"numbers are not equal", ^{
        expect(a).toNot.equal(b);
    });

    describe(@"addition", ^{

        it(@"is commutative", ^{
            expect(a + b).to.equal(b + a);
        });

    });

    describe(@"subtraction", ^{

        itShouldBehaveLike(@"subtraction", ^{
            return @{
                @"a": @(a),
                @"b": @(b),
            };
        });
        
    });
    
});

SpecEnd
