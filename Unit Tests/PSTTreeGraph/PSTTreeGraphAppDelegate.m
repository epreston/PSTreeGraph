//
//  PSTTreeGraphAppDelegate.m
//  PSTTreeGraph
//
//  Created by Ed Preston on 26/08/11.
//  Copyright 2011 Preston Software. All rights reserved.
//

#import "PSTTreeGraphAppDelegate.h"

#import "PSTTreeGraphViewController.h"

@implementation PSTTreeGraphAppDelegate


- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [_window setRootViewController:_viewController];
    [_window addSubview:_viewController.view];
    [_window makeKeyAndVisible];
    
    return YES;
}

@end
