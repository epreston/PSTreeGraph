//
//  PSBaseLeafView.h
//  PSTreeGraphView
//
//  Created by Ed Preston on 7/25/10.
//  Copyright 2010 Preston Software. All rights reserved.
//
//
// This is a port of the sample code from Max OS X to iOS (iPad).
//
// WWDC 2010 Session 141, “Crafting Custom Cocoa Views”
//


#import <UIKit/UIKit.h>


/// Draws background fill and a stroked, optionally rounded rectangular shape.  Serves as a container
/// for other views (in our case, we use a ContainerView as the root of each node subtree).
 
@interface PSBaseLeafView : UIView
{
	
@private
    UIColor *borderColor;
    CGFloat borderWidth;
    CGFloat cornerRadius;
	
    UIColor *fillColor;
	
    BOOL showingSelected;
}


#pragma mark - Styling

/// The color of the ContainerView's stroked border.
@property (nonatomic, copy) UIColor *borderColor;

/// The width of the ContainerView's stroked border.  May be zero.
@property (nonatomic, assign) CGFloat borderWidth;

/// The radius of the ContainerView's rounded corners.  May be zero.
@property (nonatomic, assign) CGFloat cornerRadius;

/// The fill color for the ContainerView's interior.
@property (nonatomic, copy) UIColor *fillColor;


#pragma mark - Selection State

@property (nonatomic, assign) BOOL showingSelected;

@end
