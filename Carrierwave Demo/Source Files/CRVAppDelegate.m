//
//  CRVAppDelegate.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVAppDelegate.h"

@implementation CRVAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [CRVNetworkManager sharedManager].serverURL = [NSURL URLWithString:@"https://carrierwave-ios-backend.herokuapp.com/"];
    return YES;
}

@end
