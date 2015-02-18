//
//  CRVManager.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 17.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVManager.h"
#import "CRVAssetModel.h"

@implementation CRVManager

#pragma mark - Public Methods

- (void)uploadImageFromModel:(CRVAssetModel *)model {

    model.uploading = YES;
    __weak typeof(self) weakSelf = self;
    
    model.proccessIdentifier = [[CRVNetworkManager sharedManager] uploadAsset:model.asset progress:^(double progress) {
        [weakSelf performProgressDelegateForModel:model withProgress:progress];
    } completion:^(CRVUploadInfo *info, NSError *error) {
        
        [model clearState];
        if (error) {
            [weakSelf performFailDelegateForModel:model withError:error];
        } else {
            model.uploadInfo = info;
            [weakSelf performSucceedDelegateForModel:model];
        }
    }];
}

- (void)downloadImageFromModel:(CRVAssetModel *)model {
    
    model.downloading = YES;
    __weak typeof(self) weakSelf = self;
    
    model.proccessIdentifier = [[CRVNetworkManager sharedManager] downloadAssetWithIdentifier:model.uploadInfo.assetIdentifier progress:^(double progress) {
        [weakSelf performProgressDelegateForModel:model withProgress:progress];
    } completion:^(CRVImageAsset *asset, NSError *error) {
        
        [model clearState];
        if (error) {
            [weakSelf performFailDelegateForModel:model withError:error];
        } else {
            model.asset = asset;
            [weakSelf performSucceedDelegateForModel:model];
        }
    }];
}

- (void)pauseProcessForModel:(CRVAssetModel *)model {
    model.suspended = YES;
    [[CRVNetworkManager sharedManager] pauseProccessWithIdentifier:model.proccessIdentifier];
}

- (void)cancelProcessForModel:(CRVAssetModel *)model {
    [model clearState];
    model.progress = 0;
    [[CRVNetworkManager sharedManager] cancelProccessWithIdentifier:model.proccessIdentifier];
}

- (void)resumeProcessForModel:(CRVAssetModel *)model {
    model.suspended = NO;
    [[CRVNetworkManager sharedManager] resumeProccessWithIdentifier:model.proccessIdentifier];
}

- (void)deleteImageFromModel:(CRVAssetModel *)model {
    
    model.deleting = YES;
    __weak typeof(self) weakSelf = self;
    
    [[CRVNetworkManager sharedManager] deleteAssetWithIdentifier:model.uploadInfo.assetIdentifier completion:^(BOOL success, NSError *error) {
        model.deleting = NO;
        if (error) {
            [weakSelf performFailDelegateForModel:model withError:error];
        } else {
            model.uploadInfo = nil;
            [weakSelf performSucceedDelegateForModel:model];
        }
    }];
}

#pragma mark - Private Methods

- (void)performProgressDelegateForModel:(CRVAssetModel *)model withProgress:(double)progress {
    model.progress = progress;
    if ([self.delegate respondsToSelector:@selector(manager:didUpdateProgress:forModel:)]) {
        [self.delegate manager:self didUpdateProgress:progress forModel:model];
    }
}

- (void)performFailDelegateForModel:(CRVAssetModel *)model withError:(NSError *)error {
    model.progress = 0;
    if ([self.delegate respondsToSelector:@selector(manager:didFailProcessAssetForModel:withError:)]) {
        [self.delegate manager:self didFailProcessAssetForModel:model withError:error];
    }
}

- (void)performSucceedDelegateForModel:(CRVAssetModel *)model {
    model.progress = 0;
    if ([self.delegate respondsToSelector:@selector(manager:didSucceedProcessAssetForModel:)]) {
        [self.delegate manager:self didSucceedProcessAssetForModel:model];
    }
}


@end
