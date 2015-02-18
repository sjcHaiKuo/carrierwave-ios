//
//  CRVButton.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 17.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSInteger, CRVButtonFunction) {
    CRVButtonFunctionCrop,
    CRVButtonFunctionUpload,
    CRVButtonFunctionDownload,
    CRVButtonFunctionPause,
    CRVButtonFunctionResume,
    CRVButtonFunctionDelete,
    CRVButtonFunctionCancel,
};

@interface CRVButton : UIButton

@property (assign, nonatomic) CRVButtonFunction function;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end
