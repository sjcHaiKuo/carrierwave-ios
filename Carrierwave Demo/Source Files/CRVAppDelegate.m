//
//  CRVAppDelegate.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVAppDelegate.h"

@implementation CRVAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    CRVImageAsset *asset = [[CRVImageAsset alloc] initWithImage:[UIImage imageNamed:@"Landscape"]];
    CRVImageEditViewController *controller = [[CRVImageEditViewController alloc] initWithImageAsset:asset];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
