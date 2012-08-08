//
//  PSBaseTreeGraphView_Internal.h
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


#import <Foundation/Foundation.h>

#import "PSTreeGraphModelNode.h"

@class PSBaseSubtreeView;

// This category declares "Internal" methods that make up part of TreeGraph's
// implementation, but aren't intended to be used as TreeGraph API.

@interface PSBaseTreeGraphView (Internal)


#pragma mark - ModelNode -> SubtreeView Relationship Management

// Returns the SubtreeView that corresponds to the specified modelNode, as
// tracked by the TreeGraph's modelNodeToSubtreeViewMapTable.

- (PSBaseSubtreeView *) subtreeViewForModelNode:(id)modelNode;

// Associates the specified subtreeView with the given modelNode in the TreeGraph's
// modelNodeToSubtreeViewMapTable, so that it can later be looked up using -subtreeViewForModelNode:

- (void) setSubtreeView:(PSBaseSubtreeView *)subtreeView
           forModelNode:(id)modelNode;


#pragma mark - Model Tree Navigation

// Returns YES if modelNode is a descendant of possibleAncestor, NO if not.
//
// Neither modelNode or possibleAncestor should be nil.

- (BOOL) modelNode:(id <PSTreeGraphModelNode> )modelNode
    isDescendantOf:(id <PSTreeGraphModelNode> )possibleAncestor;

// Returns YES if modelNode is the TreeGraph's assigned modelRoot, or a descendant of modelRoot.
//
// Returns NO if not.  TreeGraph uses this determination to avoid traversing nodes above its
// assigned modelRoot (if there are any).
//
// modelNode should not be nil.

- (BOOL) modelNodeIsInAssignedTree:(id <PSTreeGraphModelNode> )modelNode;

// Returns the sibling at the given offset relative to the given modelNode.
// (e.g. relativeIndex == -1 requests the previous sibling. relativeIndex == +1 requests the next sibling.)
//
// Returns nil if the modelNode has no sibling at the specified relativeIndex (resultant index out of bounds).
//
// This method won't go above the subtree defined by the TreeGraph's modelRoot.
// (That is: If the given modelNode is the TreeGraph's modelRoot, this method returns nil, even if
// the requested sibling exists.)
//
// Checks modelNode is nil, or if modelNode is not within the subtree assigned to the TreeGraph.
//

- (id<PSTreeGraphModelNode>) siblingOfModelNode:(id <PSTreeGraphModelNode> )modelNode
                                atRelativeIndex:(NSInteger)relativeIndex;


#pragma mark - Node View Nib Caching

//* NOT SUPPORTED ON iOS 3.2*

// Returns an UINib instance created from the TreeGraphs's nodeViewNibName.
// We automatically let go of the cachedNodeViewNib when this property changes.
// Keeping a cached UINib instance helps speed up repeated instantiation of node views.

@property (nonatomic, retain) UINib *cachedNodeViewNib;

@end
