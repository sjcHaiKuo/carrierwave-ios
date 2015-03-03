//
//  CRVCollectionViewCell.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 17.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVCollectionViewCell.h"

NSString *const CRVDemoCollectionViewCellIdentifier = @"Cell";

@interface CRVCollectionViewCell ()

@property (nonatomic, strong) UILabel *progressLabel;

@end

@implementation CRVCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.f];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.layer.borderWidth = 1.f;
        _imageView.layer.borderColor = [UIColor colorWithWhite:0.87f alpha:1.f].CGColor;
        [self.contentView addSubview:_imageView];
        
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.9f];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.font = [UIFont boldSystemFontOfSize:20.f];
        _progressLabel.textColor = [UIColor whiteColor];
        [self addSubview:_progressLabel];
        
        _leftButton = [[CRVButton alloc] init];
        _leftButton.accessibilityLabel = @"Left Button";
        [self.contentView addSubview:_leftButton];
        
        _righButton = [[CRVButton alloc] init];
        [self.contentView addSubview:_righButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    CGFloat margin = 10.f;
    CGFloat buttonHeight = 30.f;
    
    self.leftButton.frame = CGRectMake(margin,
                                       CGRectGetMaxY(rect) - buttonHeight - margin,
                                       CGRectGetMidX(rect) - 1.5f * margin,
                                       buttonHeight);
    
    self.righButton.frame = CGRectMake(CGRectGetMaxX(self.leftButton.frame) + margin,
                                       CGRectGetMinY(self.leftButton.frame),
                                       CGRectGetWidth(self.leftButton.frame),
                                       buttonHeight);
    
    self.imageView.frame = CGRectMake(margin,
                                      margin,
                                      CGRectGetWidth(rect) - 2.f * margin,
                                      CGRectGetMinY(self.leftButton.frame) - 2.f * margin);
    
    self.progressLabel.frame = self.imageView.frame;
}

- (void)setProgress:(double)progress {
    self.progressLabel.text = [NSString stringWithFormat:@"%.0f %%", progress * 100];
}

- (void)showProgress:(BOOL)show {
    self.progressLabel.hidden = !show;
}

- (void)showError:(NSError *)error {
    self.progressLabel.text = NSLocalizedString(@"Failed", nil);
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf showProgress:NO];
        [weakSelf setProgress:0];
    });
}

- (void)setInterface:(CRVCellInterface)interface {
    
    switch (interface) {
        case CRVCellInterfaceCropAndUpload:
            self.leftButton.function = CRVButtonFunctionCrop;
            self.righButton.function = CRVButtonFunctionUpload;
            break;
        case CRVCellInterfacePauseAndCancel:
            self.leftButton.function = CRVButtonFunctionPause;
            self.righButton.function = CRVButtonFunctionCancel;
            break;
        case CRVCellInterfaceDeleteAndDownload:
            self.leftButton.function = CRVButtonFunctionDelete;
            self.righButton.function = CRVButtonFunctionDownload;
            break;
        case CRVCellInterfaceResumeAndCancel:
            self.leftButton.function = CRVButtonFunctionResume;
            self.righButton.function = CRVButtonFunctionCancel;
            break;
            
        default:
            break;
    }
}

- (void)setButtonsEnabled:(BOOL)enabled {
    self.leftButton.enabled = enabled;
    self.righButton.enabled = enabled;
    
    if (!enabled) {
        self.leftButton.backgroundColor = [UIColor grayColor];
        self.righButton.backgroundColor = [UIColor grayColor];
    }
}
@end
