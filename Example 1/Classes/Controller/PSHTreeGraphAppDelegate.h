//
//  PSHTreeGraphAppDelegate.h
//  PSHTreeGraph - Example 1
//
//  Created by Ed Preston on 7/25/10.
//  Copyright Preston Software 2010. All rights reserved.
//


#import <UIKit/UIKit.h>

@class PSHTreeGraphViewController;

@interface PSHTreeGraphAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PSHTreeGraphViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PSHTreeGraphViewController *viewController;

@end

