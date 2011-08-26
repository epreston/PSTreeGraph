//
//  PSTTreeGraphAppDelegate.h
//  PSTTreeGraph
//
//  Created by Ed Preston on 26/08/11.
//  Copyright 2011 Preston Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSTTreeGraphViewController;

@interface PSTTreeGraphAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PSTTreeGraphViewController *viewController;

@end
