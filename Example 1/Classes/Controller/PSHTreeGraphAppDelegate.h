//
//  PSHTreeGraphAppDelegate.h
//  PSHTreeGraph - Example 1
//
//  Created by Ed Preston on 7/25/10.
//  Copyright Preston Software 2010. All rights reserved.
//


#import <UIKit/UIKit.h>

@class PSHTreeGraphViewController;

@interface PSHTreeGraphAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet PSHTreeGraphViewController *viewController;

@end

