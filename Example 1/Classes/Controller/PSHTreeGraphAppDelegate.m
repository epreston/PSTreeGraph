//
//  PSHTreeGraphAppDelegate.m
//  PSHTreeGraph - Example 1
//
//  Created by Ed Preston on 7/25/10.
//  Copyright Preston Software 2010. All rights reserved.
//


#import "PSHTreeGraphAppDelegate.h"
#import "PSHTreeGraphViewController.h"


@implementation PSHTreeGraphAppDelegate


#pragma mark - Application Lifecycle

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after app launch.
    [_window setRootViewController:_viewController];
    [_window addSubview:_viewController.view];
    [_window makeKeyAndVisible];

	return YES;
}


@end
