//
//  PSBaseBranchView.h
//  PSTreeGraphView
//
//  Created by Ed Preston on 7/25/10.
//  Copyright 2010 Preston Software. All rights reserved.
//
//
//  This is a port of the sample code from Max OS X to iOS (iPad).
//
//  WWDC 2010 Session 141, “Crafting Custom Cocoa Views”
//


#import <UIKit/UIKit.h>

@class PSBaseTreeGraphView;

/// Each SubtreeView has a BranchView subview that draws the connecting lines
/// between its root node and its child subtrees.

@interface PSBaseBranchView : UIView

/// @return Link to the enclosing TreeGraph.
///
/// @note The getter for this is a convenience method that ascends the view tree
/// until it encounters a TreeGraph.

@property (weak, nonatomic, readonly) PSBaseTreeGraphView *enclosingTreeGraph;

@end
