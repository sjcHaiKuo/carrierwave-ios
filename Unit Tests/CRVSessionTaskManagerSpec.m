//
//  CRVSessionTaskManagerSpec.m
//
//  Copyright 2015 Netguru Sp. z o.o. All rights reserved.
//

static NSUInteger CRVSessionTaskManagerTestWrapperIdentifier; //to follow static wrapper identifier in SUT

SpecBegin(CRVSessionTaskManagerSpec)

describe(@"CRVSessionTaskManagerSpec", ^{
    
    __block CRVSessionTaskManager *sut = nil;
    
    context(@"when newly created", ^{
        
        beforeEach(^{
            sut = [[CRVSessionTaskManager alloc] init];
        });
        
        it(@"should have no task wrappers", ^{
            expect([sut taskWrappers]).to.haveCountOf(0);
        });
    });
    
    context(@"after adding", ^{
    
        __block NSURLSessionTask *task;
        __block NSInteger initialIdentifier;
        __block NSInteger identifier;
        
        beforeAll(^{
            /* because wrapper identifier in CRVSessionTaskManager is unique across an app (is static)
             * is required to check it's value before tests begin. */
            initialIdentifier = [sut addDownloadTask:task progress:nil completion:nil];
        });

        beforeEach(^{
            sut = [[CRVSessionTaskManager alloc] init];
            task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://www.example.com"]];
        });
        
        afterEach(^{
            sut = nil; task = nil;
        });
        
        context(@"download task", ^{
            
            beforeEach(^{
                CRVSessionTaskManagerTestWrapperIdentifier ++;
                identifier = [sut addDownloadTask:task progress:nil completion:nil];
            });
            
            afterEach(^{
                identifier = 0;
            });
            
            context(@"download task wrapper", ^{
                
                it(@"identifier should be incremented.", ^{
                    expect(identifier - initialIdentifier).to.equal(CRVSessionTaskManagerTestWrapperIdentifier);
                });
                
                it(@"should exist for created task.", ^{
                    expect([sut downloadTaskWrapperForTask:task]).toNot.beNil();
                });
                
                it(@"should wrapper be proper class.", ^{
                    CRVSessionTaskWrapper *wrapper = [sut downloadTaskWrapperForTask:task];
                    expect([sut isDownloadTaskWrapper:wrapper]).to.beTruthy();
                });
            });
            
            context(@"upload task wrapper", ^{
                
                it(@"should not exist for created task.", ^{
                    expect([sut uploadTaskWrapperForTask:task]).to.beNil();
                });
            });
            
            context(@"manager", ^{
                
                it(@"should have exactly 1 download wrapper.", ^{
                    expect([sut downloadTaskWrappers]).to.haveCountOf(1);
                });
                
                it(@"should have any upload wrapper.", ^{
                    expect([sut uploadTaskWrappers]).to.beEmpty();
                });
                
                it(@"should have 1 total count of wrappers.", ^{
                    expect([sut taskWrappers]).to.haveCountOf(1);
                });
                
            });
            
            context(@"and suspending it", ^{
                
                beforeEach(^{
                    [sut pauseTaskForTaskWrapperIdentifier:identifier];
                });
                
                it(@"should have exactly 1 download wrapper.", ^{
                    expect([sut downloadTaskWrappers]).to.haveCountOf(1);
                });
                
                it(@"should have any upload wrapper.", ^{
                    expect([sut uploadTaskWrappers]).to.beEmpty();
                });
                
                it(@"should have 1 total count of wrappers.", ^{
                    expect([sut taskWrappers]).to.haveCountOf(1);
                });
                
            });
            
            context(@"and canceling it", ^{
                
                beforeEach(^{
                    [sut cancelTaskForTaskWrapperIdentifier:identifier];
                });
                
                it(@"should manager have any download wrapper.", ^{
                    expect([sut downloadTaskWrappers]).to.beEmpty();
                });
                
                it(@"should manager any wrapper.", ^{
                    expect([sut taskWrappers]).to.beEmpty();
                });
            });
            
            context(@"and canceling all tasks.", ^{
                
                beforeEach(^{
                    [sut cancelAllTasks];
                });
                
                it(@"should manager have any download wrapper.", ^{
                    expect([sut downloadTaskWrappers]).to.beEmpty();
                });
                
                it(@"should manager any wrapper.", ^{
                    expect([sut taskWrappers]).to.beEmpty();
                });
            });
            
        });

        context(@"upload task", ^{
            
            beforeEach(^{
                CRVSessionTaskManagerTestWrapperIdentifier ++;
                identifier = [sut addUploadTask:task dataStream:nil length:nil name:nil mimeType:nil progress:nil completion:nil];
            });
            
            afterEach(^{
                identifier = 0;
            });
            
            context(@"upload task wrapper", ^{
                
                it(@"identifier should be incremented.", ^{
                    expect(identifier - initialIdentifier).to.equal(CRVSessionTaskManagerTestWrapperIdentifier);
                });
                
                it(@"should exist for created task.", ^{
                    expect([sut uploadTaskWrapperForTask:task]).toNot.beNil();
                });
                
                it(@"should wrapper be proper class.", ^{
                    CRVSessionTaskWrapper *wrapper = [sut uploadTaskWrapperForTask:task];
                    expect([sut isDownloadTaskWrapper:wrapper]).to.beFalsy();
                });
            });
            
            context(@"download task wrapper", ^{
                
                it(@"should not exist for created task.", ^{
                    expect([sut downloadTaskWrapperForTask:task]).to.beNil();
                });
            });
            
            context(@"manager", ^{
                
                it(@"should have any download wrapper.", ^{
                    expect([sut downloadTaskWrappers]).to.beEmpty();
                });
                
                it(@"should have exactly 1 upload wrapper.", ^{
                    expect([sut uploadTaskWrappers]).to.haveCountOf(1);
                });
                
                it(@"should have 1 total count of wrappers.", ^{
                    expect([sut taskWrappers]).to.haveCountOf(1);
                });
                
            });
            
            context(@"and suspending it", ^{
                
                beforeEach(^{
                    [sut pauseTaskForTaskWrapperIdentifier:identifier];
                });
                
                it(@"should have any download wrapper.", ^{
                    expect([sut downloadTaskWrappers]).to.beEmpty();
                });
                
                it(@"should have exactly 1 upload wrapper.", ^{
                    expect([sut uploadTaskWrappers]).to.haveCountOf(1);
                });
                
                it(@"should have 1 total count of wrappers.", ^{
                    expect([sut taskWrappers]).to.haveCountOf(1);
                });
                
            });
            
            context(@"and canceling it", ^{
                
                beforeEach(^{
                    [sut cancelTaskForTaskWrapperIdentifier:identifier];
                });
                
                it(@"should manager have any upload wrapper.", ^{
                    expect([sut downloadTaskWrappers]).to.beEmpty();
                });
                
                it(@"should manager any wrapper.", ^{
                    expect([sut taskWrappers]).to.beEmpty();
                });
            });
            
            context(@"and canceling all tasks.", ^{
                
                beforeEach(^{
                    [sut cancelAllTasks];
                });
                
                it(@"should manager have any upload wrapper.", ^{
                    expect([sut downloadTaskWrappers]).to.beEmpty();
                });
                
                it(@"should manager any wrapper.", ^{
                    expect([sut taskWrappers]).to.beEmpty();
                });
            });
        
        });
    });
});

SpecEnd
