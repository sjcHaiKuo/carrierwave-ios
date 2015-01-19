//
//  CRVSessionTaskManagerSpec.m
//
//  Copyright 2015 Netguru Sp. z o.o. All rights reserved.
//

static NSUInteger CRVSessionTaskManagerTestWrapperIdentifier; //to follow static wrapper identifier in SUT

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
    
        __block NSURLSessionTask *task;
        __block NSInteger initialIdentifier;
        __block NSInteger identifier;
        
        beforeAll(^{
            /* because wrapper identifier in CRVSessionTaskManager is unique across an app (is static)
             * is required to check it's value before tests begin. */
            initialIdentifier = [manager addDownloadTask:task progress:nil completion:nil];
        });

        beforeEach(^{
            manager = [[CRVSessionTaskManager alloc] init];
            task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://www.example.com"]];
        });
        
        afterEach(^{
            manager = nil; task = nil;
        });
        
        context(@"download task", ^{
            
            beforeEach(^{
                CRVSessionTaskManagerTestWrapperIdentifier ++;
                identifier = [manager addDownloadTask:task progress:nil completion:nil];
            });
            
            afterEach(^{
                identifier = 0;
            });
            
            context(@"download task wrapper", ^{
                
                it(@"identifier should be incremented.", ^{
                    expect(identifier - initialIdentifier).to.equal(CRVSessionTaskManagerTestWrapperIdentifier);
                });
                
                it(@"should exist for created task.", ^{
                    expect([manager downloadTaskWrapperForTask:task]).toNot.beNil();
                });
                
                it(@"should wrapper be proper class.", ^{
                    CRVSessionTaskWrapper *wrapper = [manager downloadTaskWrapperForTask:task];
                    expect([manager isDownloadTaskWrapper:wrapper]).to.beTruthy();
                });
            });
            
            context(@"upload task wrapper", ^{
                
                it(@"should not exist for created task.", ^{
                    expect([manager uploadTaskWrapperForTask:task]).to.beNil();
                });
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

        context(@"upload task", ^{
            
            beforeEach(^{
                CRVSessionTaskManagerTestWrapperIdentifier ++;
                identifier = [manager addUploadTask:task dataStream:nil length:nil name:nil mimeType:nil progress:nil completion:nil];
            });
            
            afterEach(^{
                identifier = 0;
            });
            
            context(@"upload task wrapper", ^{
                
                it(@"identifier should be incremented.", ^{
                    expect(identifier - initialIdentifier).to.equal(CRVSessionTaskManagerTestWrapperIdentifier);
                });
                
                it(@"should exist for created task.", ^{
                    expect([manager uploadTaskWrapperForTask:task]).toNot.beNil();
                });
                
                it(@"should wrapper be proper class.", ^{
                    CRVSessionTaskWrapper *wrapper = [manager uploadTaskWrapperForTask:task];
                    expect([manager isDownloadTaskWrapper:wrapper]).to.beFalsy();
                });
            });
            
            context(@"download task wrapper", ^{
                
                it(@"should not exist for created task.", ^{
                    expect([manager downloadTaskWrapperForTask:task]).to.beNil();
                });
            });
            
            context(@"manager", ^{
                
                it(@"should have any download wrapper.", ^{
                    expect([manager downloadTaskWrappers]).to.beEmpty();
                });
                
                it(@"should have exactly 1 upload wrapper.", ^{
                    expect([manager uploadTaskWrappers]).to.haveCountOf(1);
                });
                
                it(@"should have 1 total count of wrappers.", ^{
                    expect([manager taskWrappers]).to.haveCountOf(1);
                });
                
            });
            
            context(@"and suspending it", ^{
                
                beforeEach(^{
                    [manager pauseTaskForTaskWrapperIdentifier:identifier];
                });
                
                it(@"should have any download wrapper.", ^{
                    expect([manager downloadTaskWrappers]).to.beEmpty();
                });
                
                it(@"should have exactly 1 upload wrapper.", ^{
                    expect([manager uploadTaskWrappers]).to.haveCountOf(1);
                });
                
                it(@"should have 1 total count of wrappers.", ^{
                    expect([manager taskWrappers]).to.haveCountOf(1);
                });
                
            });
            
            context(@"and canceling it", ^{
                
                beforeEach(^{
                    [manager cancelTaskForTaskWrapperIdentifier:identifier];
                });
                
                it(@"should manager have any upload wrapper.", ^{
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
                
                it(@"should manager have any upload wrapper.", ^{
                    expect([manager downloadTaskWrappers]).to.beEmpty();
                });
                
                it(@"should manager any wrapper.", ^{
                    expect([manager taskWrappers]).to.beEmpty();
                });
            });
        
        });
    });
});

SpecEnd

