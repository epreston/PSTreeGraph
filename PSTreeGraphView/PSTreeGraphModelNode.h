//
//  PSTreeGraphModelNode.h
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

/// The model nodes used with a TreeGraph are required to conform to the this protocol,
/// which enables the TreeGraph to navigate the model tree to find related nodes.

@protocol PSTreeGraphModelNode <NSObject>

@required

/// The model node's parent node, or nil if it doesn't have a parent node.

- (id <PSTreeGraphModelNode> )parentModelNode;

/// The model node's child nodes.  If the node has no children, this should return an
/// empty array ([NSArray array]), not nil.

- (NSArray *) childModelNodes;

@end



@protocol PSTreeGraphDelegate <NSObject>

@required

/// The delegate will configure the nodeView with the modelNode provided.

- (void) configureNodeView:(UIView *)nodeView withModelNode:(id <PSTreeGraphModelNode> )modelNode;

@end



