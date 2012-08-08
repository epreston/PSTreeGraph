//
//  PSTreeGraphDelegate.h
//  PSTreeGraphView
//
//  Created by Ed Preston on 9/08/12.
//  Copyright (c) 2012 Preston Software. All rights reserved.
//
//
//  This is a port of the sample code from Max OS X to iOS (iPad).
//
//  WWDC 2010 Session 141, “Crafting Custom Cocoa Views”
//


#import <Foundation/Foundation.h>

// Forward declaration of Model Node

@protocol PSTreeGraphModelNode;


@protocol PSTreeGraphDelegate <NSObject>

@required

/// The delegate will configure the nodeView with the modelNode provided.

- (void) configureNodeView:(UIView *)nodeView withModelNode:(id <PSTreeGraphModelNode> )modelNode;

@end