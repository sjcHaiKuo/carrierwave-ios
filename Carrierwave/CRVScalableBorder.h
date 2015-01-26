//
//  CRVScalableBorder.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 22.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat CRVBorderInset;

@interface CRVScalableBorder : UIView

@property (nonatomic, assign, getter=isResizing) BOOL resizing;

//default 5:
@property (nonatomic, assign) CGFloat borderInset;
//default 2:
@property (nonatomic, assign) CGFloat anchorThickness;

@end
