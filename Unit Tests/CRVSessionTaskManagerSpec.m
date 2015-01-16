//
//  CRVSessionTaskManagerSpec.m
//
//  Copyright 2015 Netguru Sp. z o.o. All rights reserved.
//

static NSUInteger CRVTestPurposeWrapperIdentifier; //to follow static wrapper identifier in SUT

SpecBegin(CRVSessionTaskManagerSpec)

describe(@"CRVSessionTaskManagerSpec", ^{
    
    __block CRVSessionTaskManager *manager = nil;
    
    context(@"when newly created", ^{
        
        beforeEach(^{
            manager = [[CRVSessionTaskManager alloc] init];
        });
        
        it(@"should have no task wrappers", ^{
            expect([manager taskWrappers]).to.haveCountOf(0);
        });
    });
    
    context(@"after adding", ^{
    
        __block CRVSessionTaskWrapper *wrapper;
        __block NSURLSessionTask *task;
        __block NSInteger initialIdentifier;
        __block NSInteger identifier;

        beforeEach(^{
            manager = [[CRVSessionTaskManager alloc] init];
            task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://www.example.com"]];
        });
        
        afterEach(^{
            manager = nil; task = nil;
        });
        
        context(@"download task", ^{
            
            beforeAll(^{
                /* because wrapper identifier in CRVSessionTaskManager is unique across an app (is static)
                 * is required to check it's value before tests begin. */
                initialIdentifier = [manager addDownloadTask:task progress:nil completion:nil];
            });
            
            beforeEach(^{
                CRVTestPurposeWrapperIdentifier ++;
                identifier = [manager addDownloadTask:task progress:nil completion:nil];
                wrapper = [manager downloadTaskWrapperForTask:task];
            });
            
            afterEach(^{
                identifier = 0; wrapper = nil;
            });
            
            it(@"should task wrapper identifier be incremented.", ^{
                expect(identifier - initialIdentifier).to.equal(CRVTestPurposeWrapperIdentifier);
            });
            
            it(@"should exist download wrapper for task.", ^{
                expect([manager downloadTaskWrapperForTask:task]).toNot.beNil();
            });
            
            it(@"should not exist upload wrapper for task.", ^{
                expect([manager uploadTaskWrapperForTask:task]).to.beNil();
            });
            
            it(@"should wrapper be same as retrieved one from task.", ^{
                expect(wrapper).to.beIdenticalTo([manager downloadTaskWrapperForTask:task]);
            });
            
            it(@"should wrapper be proper class.", ^{
                expect([manager isDownloadTaskWrapper:wrapper]).to.beTruthy();
            });
            
            context(@"manager", ^{
                
                it(@"should have exactly 1 download wrapper.", ^{
                    expect([manager downloadTaskWrappers]).to.haveCountOf(1);
                });
                
                it(@"should have any upload wrapper.", ^{
                    expect([manager uploadTaskWrappers]).to.beEmpty();
                });
                
                it(@"should have 1 total count of wrappers.", ^{
                    expect([manager taskWrappers]).to.haveCountOf(1);
                });
                
            });
            
            context(@"and suspending it", ^{
                
                beforeEach(^{
                    [manager pauseTaskForTaskWrapperIdentifier:identifier];
                });
                
                it(@"should have exactly 1 download wrapper.", ^{
                    expect([manager downloadTaskWrappers]).to.haveCountOf(1);
                });
                
                it(@"should have any upload wrapper.", ^{
                    expect([manager uploadTaskWrappers]).to.beEmpty();
                });
                
                it(@"should have 1 total count of wrappers.", ^{
                    expect([manager taskWrappers]).to.haveCountOf(1);
                });
                
            });
            
            context(@"and canceling it", ^{
                
                beforeEach(^{
                    [manager cancelTaskForTaskWrapperIdentifier:identifier];
                });
                
                it(@"should manager have any download wrapper.", ^{
                    expect([manager downloadTaskWrappers]).to.beEmpty();
                });
                
                it(@"should manager any wrapper.", ^{
                    expect([manager taskWrappers]).to.beEmpty();
                });
            });
            
            context(@"and canceling all tasks.", ^{
                
                beforeEach(^{
                    [manager cancelAllTasks];
                });
                
                it(@"should manager have any download wrapper.", ^{
                    expect([manager downloadTaskWrappers]).to.beEmpty();
                });
                
                it(@"should manager any wrapper.", ^{
                    expect([manager taskWrappers]).to.beEmpty();
                });
            });
            
        });

        pending(@"upload task");
    });
});

SpecEnd

