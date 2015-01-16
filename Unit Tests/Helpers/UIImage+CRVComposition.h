//
//  UIImage+CRVComposition.h
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * The CRVComposition category provides an easy interface to create images
 * programatically for testing purposes.
 */
@interface UIImage (CRVComposition)

/**
 * Creates an image of the given size and opaque background of the given color.
 *
 * @param size The size of the image.
 * @param color The background color of the image.
 *
 * @return An initialized receiver.
 */
+ (instancetype)crv_composeImageWithSize:(CGSize)size color:(UIColor *)color;

/**
 *  Creates an image for test purposes.
 *
 *  @return An initialized receiver.
 */
+ (instancetype)crv_composeTestImage;

@end
