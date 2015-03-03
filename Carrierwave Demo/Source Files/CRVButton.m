//
//  CRVButton.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 17.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVButton.h"

@implementation CRVButton

- (instancetype)init {
    self = [super init];
    if (self) {
        self.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return self;
}

- (void)setFunction:(CRVButtonFunction)function {
    
    UIColor *color;
    NSString *title;
    NSString *accessibilityLabel;
    
    switch (function) {
        case CRVButtonFunctionCrop:
            color = [UIColor greenColor];
            title = NSLocalizedString(@"Crop", nil);
            accessibilityLabel = @"Crop";
            break;
        case CRVButtonFunctionUpload:
            color = [UIColor purpleColor];
            title = NSLocalizedString(@"Upload", nil);
            accessibilityLabel = @"Upload";
            break;
        case CRVButtonFunctionDownload:
            color = [UIColor purpleColor];
            title = NSLocalizedString(@"Download", nil);
            accessibilityLabel = @"Download";
            break;
        case CRVButtonFunctionPause:
            color = [UIColor blueColor];
            title = NSLocalizedString(@"Pause", nil);
            accessibilityLabel = @"Pause";
            break;
        case CRVButtonFunctionDelete:
            color = [UIColor redColor];
            title = NSLocalizedString(@"Delete", nil);
            accessibilityLabel = @"Delete";
            break;
        case CRVButtonFunctionCancel:
            color = [UIColor redColor];
            title = NSLocalizedString(@"Cancel", nil);
            accessibilityLabel = @"Cancel";
            break;
        case CRVButtonFunctionResume:
            color = [UIColor greenColor];
            title = NSLocalizedString(@"Resume", nil);
            accessibilityLabel = @"Resume";
            break;
        default:
            color = [UIColor grayColor];
            title = @"";
            break;
    }
    
    self.backgroundColor = color;
    [self setTitle:title forState:UIControlStateNormal];
    self.accessibilityLabel = accessibilityLabel;
    
    _function = function;
}

@end
