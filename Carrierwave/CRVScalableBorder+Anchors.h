//
//  CRVScalableBorder+Anchors.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 27.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVScalableBorder.h"

@interface CRVScalableBorder (Anchors)

/**
 *  Draws apple photo-app like style anchors.
 *
 *  @param context The context where anchors should be drawn.
 */
- (void)drawAppleStyleAnchorsInContext:(CGContextRef)context;

@end
