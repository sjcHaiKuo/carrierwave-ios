//
//  CRVAlertController.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 25.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVAlertController.h"
#import "CRVRatioItem.h"

@interface CRVAlertController ()

@property (copy, nonatomic) CRVActionHandler actionHandler;
@property (strong, nonatomic) NSArray *list;

@end

@implementation CRVAlertController

- (instancetype)initWithList:(NSArray *)list actionHandler:(CRVActionHandler)handler {
    self = [[self class] alertControllerWithTitle:NSLocalizedString(@"Select crop rectangle ratio:", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if (self) {
        _actionHandler = handler;
        _list = list;
        
        for (CRVRatioItem *item in list) {
            [self addActionWithTitle:item.title];
        }
        
        [self addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    }
    return self;
}
             
- (void)addActionWithTitle:(NSString *)title {
    
    [self addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self.actionHandler) {
            self.actionHandler([self ratioForTitle:title]);
        }
    }]];
}

- (CGFloat)ratioForTitle:(NSString *)title {
    for (CRVRatioItem *item in self.list) {
        if ([item.title isEqualToString:title]) {
            return item.ratio;
        }
    }
    return 0.f;
}

@end
