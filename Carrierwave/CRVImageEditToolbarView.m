//
//  CRVImageEditToolbarView.m
//  Carrierwave
//
//  Created by Paweł Białecki on 12.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVImageEditToolbarView.h"

@implementation CRVImageEditToolbarView

- (UIColor *)toolbarBackgroundColor {
    return [[UIColor blackColor] colorWithAlphaComponent:0.8f];
}

- (UISlider *)rotationSlider {
    UISlider *rotationSlider = [[UISlider alloc] init];
    
    rotationSlider.tintColor = [[UIColor blueColor] colorWithAlphaComponent:0.8f];
    rotationSlider.backgroundColor = [UIColor clearColor];
    rotationSlider.minimumValue = -90.f;
    rotationSlider.maximumValue = 90.f;
    rotationSlider.value = 0;
    rotationSlider.continuous = YES;
    
    return rotationSlider;
}

- (UIBarButtonItem *)cancelBarButtonItem {
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] init];
    
    cancelBarButtonItem.title = @"Cancel";
    cancelBarButtonItem.style = UIBarButtonItemStylePlain;
    cancelBarButtonItem.tintColor = [[UIColor redColor] colorWithAlphaComponent:0.8f];
    
    return cancelBarButtonItem;
}

- (UIBarButtonItem *)ratioBarButtonItem {
    UIBarButtonItem *ratioBarButtonItem = [[UIBarButtonItem alloc] init];
    
    ratioBarButtonItem.title = @"Select crop ratio";
    ratioBarButtonItem.style = UIBarButtonItemStylePlain;
    ratioBarButtonItem.tintColor = [[UIColor blueColor] colorWithAlphaComponent:0.8f];
    
    return ratioBarButtonItem;
}

- (UIBarButtonItem *)doneBarButtonItem {
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] init];
    
    doneBarButtonItem.title = @"Done";
    doneBarButtonItem.style = UIBarButtonItemStyleDone;
    doneBarButtonItem.tintColor = [[UIColor yellowColor] colorWithAlphaComponent:0.8f];
    
    return doneBarButtonItem;
}

@end
