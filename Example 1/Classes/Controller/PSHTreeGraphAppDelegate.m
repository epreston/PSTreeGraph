//
//  PSHTreeGraphAppDelegate.m
//  PSHTreeGraph - Example 1
//
//  Created by Ed Preston on 7/25/10.
//  Copyright Preston Software 2010. All rights reserved.
//


#import "PSHTreeGraphAppDelegate.h"
#import "PSHTreeGraphViewController.h"


#pragma mark - Internal Interface

@interface PSHTreeGraphAppDelegate () 
{

@private
    UIWindow *window_;
    PSHTreeGraphViewController *viewController_;
}

@end


@implementation PSHTreeGraphAppDelegate


@synthesize window = window_;
@synthesize viewController = viewController_;


#pragma mark - Application Lifecycle

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after app launch.
    [window_ addSubview:viewController_.view];
    [window_ makeKeyAndVisible];

	return YES;
}


#pragma mark - Resouce Management

- (void) dealloc
{
    [viewController_ release];
    [window_ release];
    [super dealloc];
}


@end
