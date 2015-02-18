//
//  CRVManager.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 17.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;
@class CRVManager, CRVAssetModel;

@protocol CRVManagerDelegate <NSObject>

@optional

- (void)manager:(CRVManager *)manager didUpdateProgress:(double)progress forModel:(CRVAssetModel *)model;
- (void)manager:(CRVManager *)manager didSucceedProcessAssetForModel:(CRVAssetModel *)model;
- (void)manager:(CRVManager *)manager didFailProcessAssetForModel:(CRVAssetModel *)model withError:(NSError *)error;

@end

@interface CRVManager : NSObject

@property (weak, nonatomic) id<CRVManagerDelegate> delegate;

- (void)uploadImageFromModel:(CRVAssetModel *)model;
- (void)downloadImageFromModel:(CRVAssetModel *)model;
- (void)pauseProcessForModel:(CRVAssetModel *)model;
- (void)cancelProcessForModel:(CRVAssetModel *)model;
- (void)resumeProcessForModel:(CRVAssetModel *)model;
- (void)deleteImageFromModel:(CRVAssetModel *)model;

@end
