//
//  NSData+CRVComposition.h
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 15.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;

@interface NSData (CRVComposition)

/**
 *  Creates an image represented by data for test purposes.
 *
 * @return An initialized receiver.
 */
+ (instancetype)crv_defaultImageDataRepresentation;

@end
