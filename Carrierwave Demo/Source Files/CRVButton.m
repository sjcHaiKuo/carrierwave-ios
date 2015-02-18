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
    
    switch (function) {
        case CRVButtonFunctionCrop:
            color = [UIColor greenColor];
            title = NSLocalizedString(@"Crop", nil);
            break;
        case CRVButtonFunctionUpload:
            color = [UIColor purpleColor];
            title = NSLocalizedString(@"Upload", nil);
            break;
        case CRVButtonFunctionDownload:
            color = [UIColor purpleColor];
            title = NSLocalizedString(@"Download", nil);
            break;
        case CRVButtonFunctionPause:
            color = [UIColor blueColor];
            title = NSLocalizedString(@"Pause", nil);
            break;
        case CRVButtonFunctionDelete:
            color = [UIColor redColor];
            title = NSLocalizedString(@"Delete", nil);
            break;
        case CRVButtonFunctionCancel:
            color = [UIColor redColor];
            title = NSLocalizedString(@"Cancel", nil);
            break;
        case CRVButtonFunctionResume:
            color = [UIColor greenColor];
            title = NSLocalizedString(@"Resume", nil);
            break;
        default:
            color = [UIColor grayColor];
            title = @"";
            break;
    }
    
    self.backgroundColor = color;
    [self setTitle:title forState:UIControlStateNormal];
    
    _function = function;
}

@end
