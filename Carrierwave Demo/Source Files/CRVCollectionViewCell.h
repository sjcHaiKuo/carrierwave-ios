//
//  CRVCollectionViewCell.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 17.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import UIKit;
#import "CRVButton.h"

typedef NS_ENUM(NSInteger, CRVCellInterface) {
    CRVCellInterfaceCropAndUpload,
    CRVCellInterfacePauseAndCancel,
    CRVCellInterfaceResumeAndCancel,
    CRVCellInterfaceDeleteAndDownload
};

extern NSString *const CRVDemoCollectionViewCellIdentifier;

@interface CRVCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) CRVButton *leftButton;
@property (strong, nonatomic) CRVButton *righButton;
@property (assign, nonatomic) CRVCellInterface interface;

- (void)setProgress:(double)progress;
- (void)showProgress:(BOOL)show;
- (void)showError:(NSError *)error;
- (void)setButtonsEnabled:(BOOL)enabled;

@end
