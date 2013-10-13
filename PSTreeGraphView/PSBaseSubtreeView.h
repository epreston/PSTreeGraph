//
//  PSBaseSubtreeView.h
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

#import "PSTreeGraphModelNode.h"


@class PSBaseTreeGraphView;


/// A SubtreeView draws nothing itself (unless showsSubtreeFrames is set to YES for
/// the enclosingTreeGraph), but provides a local coordinate frame and grouping mechanism
/// for a graph subtree, and implements subtree layout.


@interface PSBaseSubtreeView : UIView

/// Initializes a SubtreeView with the associated modelNode.  This is SubtreeView's designated initializer.

- initWithModelNode:( id <PSTreeGraphModelNode> )newModelNode;

/// The root of the model subtree that this SubtreeView represents.

@property (nonatomic, strong) id <PSTreeGraphModelNode> modelNode;

/// The view that represents the modelNode.  Is a subview of SubtreeView, and may itself have descendant views.

@property (nonatomic, weak) IBOutlet UIView *nodeView;

/// Link to the enclosing TreeGraph.  (The getter for this is a convenience method that ascends
/// the view tree until it encounters a TreeGraph.)

@property (weak, nonatomic, readonly) PSBaseTreeGraphView *enclosingTreeGraph;

// Whether the model node represented by this SubtreeView is a leaf node (one without child nodes).  This
// can be a useful property to bind user interface state to.  In the TreeGraph demo app, for example,
// we've bound the "isHidden" property of subtree expand/collapse buttons to this, so that expand/collapse
// buttons will only be shown for non-leaf nodes.

@property (nonatomic, readonly, getter=isLeaf) BOOL leaf;


#pragma mark - Selection State

/// Whether the node is part of the TreeGraph's current selection.  This can be a useful property to bind user
/// interface state to.

@property (nonatomic, readonly) BOOL nodeIsSelected;


#pragma mark - Layout

/// Returns YES if this subtree needs relayout.

@property (nonatomic, assign) BOOL needsGraphLayout;

/// Recursively marks this subtree, and all of its descendants, as needing relayout.

- (void) recursiveSetNeedsGraphLayout;

/// Recursively performs graph layout, if this subtree is marked as needing it.

- (CGSize) layoutGraphIfNeeded;

// Flip the treeGraph end for end (or top for bottom)
- (void) flipTreeGraph;

/// Resizes this subtree's nodeView to the minimum size required to hold its content, and returns the nodeView's
/// new size.  (This currently does nothing, and is just stubbed out for future use.)

- (CGSize) sizeNodeViewToFitContent;

/// Whether this subtree is currently shown as expanded.  If NO, the node's children have been collapsed into it.

@property (nonatomic, assign, getter=isExpanded) BOOL expanded;

/// Toggles expansion of this subtree.  This can be wired up as the action of a button or other user interface
/// control.

- (IBAction) toggleExpansion:(id)sender;


#pragma mark - Invalidation

/// Marks all BranchView instances in this subtree as needing display.

- (void) recursiveSetConnectorsViewsNeedDisplay;

/// Marks all SubtreeView debug borders as needing display.

- (void) resursiveSetSubtreeBordersNeedDisplay;


#pragma mark - Node Hit-Testing

/// Returns the visible model node whose nodeView contains the given point "p", where "p" is specified in the
/// SubtreeView's interior (bounds) coordinate space.  Returns nil if there is no node under the specified point.
/// When a subtree is collapsed, only its root nodeView is eligible for hit-testing.

- ( id <PSTreeGraphModelNode> ) modelNodeAtPoint:(CGPoint)p;

/// Returns the visible model node that is closest to the specified y coordinate, where "y" is specified in the
/// SubtreeView's interior (bounds) coordinate space.

- ( id <PSTreeGraphModelNode> ) modelNodeClosestToY:(CGFloat)y;

/// Returns the visible model node that is closest to the specified x coordinate, where "x" is specified in the
/// SubtreeView's interior (bounds) coordinate space.

- ( id <PSTreeGraphModelNode> ) modelNodeClosestToX:(CGFloat)x;


#pragma mark - Debugging

/// Returns an indented multi-line NSString summary of the displayed tree.  Provided as a debugging aid.

- (NSString *) treeSummaryWithDepth:(NSInteger)depth;

@end
