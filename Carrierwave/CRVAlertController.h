//
//  CRVAlertController.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 25.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import UIKit;

typedef void (^CRVActionHandler)(CGFloat ratio);

@interface CRVAlertController : UIAlertController

- (instancetype)initWithList:(NSArray *)list actionHandler:(CRVActionHandler)handler;

@end
