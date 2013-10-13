//
//  PSHTreeGraphViewController.h
//  PSHTreeGraph - Example 1
//
//  Created by Ed Preston on 7/25/10.
//  Copyright Preston Software 2010. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "PSTreeGraphDelegate.h"


@class PSBaseTreeGraphView;


@interface PSHTreeGraphViewController : UIViewController <PSTreeGraphDelegate>

// The TreeGraph
@property(nonatomic, weak) IBOutlet PSBaseTreeGraphView *treeGraphView;

// The name of the root class that the TreeGraph is currently showing.
@property(nonatomic, copy) NSString *rootClassName;

@end

