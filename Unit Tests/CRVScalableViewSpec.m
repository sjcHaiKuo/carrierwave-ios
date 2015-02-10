//
//  CRVScalableViewSpec.m
//  Carrierwave
//
//  Created by Paweł Białecki on 09.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVScalableViewSpec)

describe(@"CRVScalableViewSpec", ^{
    
    __block CRVScalableView *scalableView = nil;
    
    beforeEach(^{
        CGRect frame = CGRectMake(100, 100, 100, 100);
        scalableView = [[CRVScalableView alloc] initWithFrame:frame];
    });
    
    afterEach(^{
        scalableView = nil;
    });
    
    context(@"when newly created", ^{
        
        it(@"should be initialized properly", ^{
            expect(scalableView).toNot.beNil();
            expect(scalableView.borderView).toNot.beNil();
            expect(scalableView.ratioEnabled).to.beFalsy();
            expect(scalableView.minSize).to.equal(CGSizeMake(50.f, 50.f));
            expect(scalableView.maxSize).to.equal(CGSizeMake(300.f, 300.f));
            expect(scalableView.animationDuration).to.equal(1.0f);
            expect(scalableView.animationCurve).to.equal(UIViewAnimationOptionCurveEaseInOut);
            expect(scalableView.springDamping).to.equal(0.9f);
            expect(scalableView.springVelocity).to.equal(13.f);
        });
    });
    
    describe(@"when setting minimal size", ^{
        
        context(@"with negative width value", ^{
            
            it(@"should raise an exception", ^{
                expect(^{
                    scalableView.minSize = CGSizeMake(-5.f, -10.f);
                }).to.raiseWithReason(NSInternalInconsistencyException, @"Min width cannot be smaller or equal to 0!");
            });
            
        });
        
        context(@"with negative height value", ^{
           
            it(@"should raise an exception", ^{
                expect(^{
                    scalableView.minSize = CGSizeMake(10.f, -5.f);
                }).to.raiseWithReason(NSInternalInconsistencyException, @"Min height cannot be smaller or equal to 0!");
            });
            
        });
        
        context(@"with zero width value", ^{
            
            it(@"should raise an exception", ^{
                expect(^{
                    scalableView.minSize = CGSizeMake(0, 10.f);
                }).to.raiseWithReason(NSInternalInconsistencyException, @"Min width cannot be smaller or equal to 0!");
            });
            
        });
        
        context(@"with zero height value", ^{
            
            it(@"should raise an exception", ^{
                expect(^{
                    scalableView.minSize = CGSizeMake(30.f, 0);
                }).to.raiseWithReason(NSInternalInconsistencyException, @"Min height cannot be smaller or equal to 0!");
            });
            
        });
        
        context(@"with positive values", ^{
            
            it(@"should run without any problems", ^{
                expect(^{
                    scalableView.minSize = CGSizeMake(10.f, 20.f);
                }).toNot.raise(NSInternalInconsistencyException);
            });
            
        });
    });
});

SpecEnd
