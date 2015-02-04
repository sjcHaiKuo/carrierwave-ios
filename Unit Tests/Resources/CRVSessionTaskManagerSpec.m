//
//  CRVSessionTaskManagerSpec.m
//
//  Copyright 2015 Netguru Sp. z o.o. All rights reserved.
//

SpecBegin(CRVSessionTaskManagerSpec)

describe(@"CRVSessionTaskManagerSpec", ^{
    
    __block CRVSessionTaskManager *manager = nil;
    
    beforeEach(^{
        manager = [[CRVSessionTaskManager alloc] init];
    });
    
    afterEach(^{
        manager = nil;
    });
    
    context(@"when newly created", ^{
        
        it(@"should have no task wrappers.", ^{
            expect([manager taskWrappers]).to.haveCountOf(0);
        });
    });
    
    context(@"after adding", ^{
    
        __block NSURLSessionTask *task;
        __block NSString *identifier;

        beforeEach(^{
            task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://www.example.com"]];
        });
        
        afterEach(^{
            task = nil;
        });
        
        context(@"download task", ^{
            
            beforeEach(^{
                identifier = [manager addDownloadTask:task progress:nil completion:nil];
            });
            
            afterEach(^{
                identifier = nil;
            });
            
            context(@"download task wrapper", ^{
                
                it(@"identifier should be same as saved one.", ^{
                    CRVSessionTaskWrapper *wrapper = [manager downloadTaskWrapperForTask:task];
                    expect(wrapper.identifier).to.equal(identifier);
                });
                
                it(@"should exist for created task.", ^{
                    expect([manager downloadTaskWrapperForTask:task]).toNot.beNil();
                });
                
                it(@"should wrapper be proper class.", ^{
                    CRVSessionTaskWrapper *wrapper = [manager downloadTaskWrapperForTask:task];
                    expect([wrapper isDownloadTask]).to.beTruthy();
                    expect([wrapper isUploadTask]).to.beFalsy();
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
                
                it(@"should manager have any wrapper.", ^{
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
                
                it(@"should manager have any wrapper.", ^{
                    expect([manager taskWrappers]).to.beEmpty();
                });
            });
            
        });

        context(@"upload task", ^{
            
            beforeEach(^{
                identifier = [manager addUploadTask:task dataStream:nil length:nil name:nil mimeType:nil progress:nil completion:nil];
            });
            
            afterEach(^{
                identifier = nil;
            });
            
            context(@"upload task wrapper", ^{
                
                it(@"identifier should be same as saved one.", ^{
                    CRVSessionTaskWrapper *wrapper = [manager uploadTaskWrapperForTask:task];
                    expect(wrapper.identifier).to.equal(identifier);
                });
                
                it(@"should exist for created task.", ^{
                    expect([manager uploadTaskWrapperForTask:task]).toNot.beNil();
                });
                
                it(@"should wrapper be proper class.", ^{
                    CRVSessionTaskWrapper *wrapper = [manager uploadTaskWrapperForTask:task];
                    expect([wrapper isUploadTask]).to.beTruthy();
                    expect([wrapper isDownloadTask]).to.beFalsy();
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
                
                it(@"should manager have any wrapper.", ^{
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
                
                it(@"should manager have any wrapper.", ^{
                    expect([manager taskWrappers]).to.beEmpty();
                });
            });
        
        });
    });
});

SpecEnd
