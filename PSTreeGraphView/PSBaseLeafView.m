//
//  PSBaseLeafView.m
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


#import "PSBaseLeafView.h"


// for CALayer definition
#import <QuartzCore/QuartzCore.h>


@implementation PSBaseLeafView


#pragma mark - Update Layer

- (void) updateLayerAppearanceToMatchContainerView 
{
    CALayer *layer = [self layer];
    if (layer) {
		
        // Disable implicit animations during these layer property changes, to make them take effect immediately.
        // BOOL actionsWereDisabled = [CATransaction disableActions];
        // [CATransaction setDisableActions:YES];
		
        // Apply the ContainerView's appearance properties to its backing layer.  
        // Important: While UIView metrics are conventionally expressed in points, CALayer metrics are
        // expressed in pixels.  To produce the correct borderWidth and cornerRadius to apply to the 
        // layer, we must multiply by the window's userSpaceScaleFactor (which is normally 1.0, but may
        // be larger on a higher-resolution display) to yield pixel units.
		
		// [layer setBackgroundColor:[[self fillColor] CGColor] ];
		
        // CGFloat scaleFactor = [[self window] userSpaceScaleFactor];
		CGFloat scaleFactor = 1.0f;
		
        [layer setBorderWidth:(borderWidth * scaleFactor)];
        if (borderWidth > 0.0f) {
            [layer setBorderColor:[borderColor CGColor]];
        }
		
        [layer setCornerRadius:(cornerRadius * scaleFactor)];
		
		if ( showingSelected ) {
			[layer setBackgroundColor:[[UIColor yellowColor] CGColor] ];
		} else {
			[layer setBackgroundColor:[[self fillColor] CGColor] ];
		}
		
        // [CATransaction setDisableActions:actionsWereDisabled];
    } else {
		[self setNeedsDisplay];
    }
}


#pragma mark - Initialization

- (void) configureDetaults 
{
	// Initialize ivars directly.  As a rule, it's best to avoid invoking accessors from an -init...
	// method, since they may wrongly expect the instance to be fully formed.
	
	borderColor = [[UIColor colorWithRed:1.0f green:0.8f blue:0.4f alpha:1.0f] retain];
	borderWidth = 3.0f;
	cornerRadius = 8.0f;
	fillColor = [[UIColor colorWithRed:1.0f green:0.5f blue:0.0f alpha:1.0f] retain];
    showingSelected = NO;
	
	[self updateLayerAppearanceToMatchContainerView];
}

- initWithFrame:(CGRect)newFrame 
{
    self = [super initWithFrame:newFrame];
    if (self) {
		[self configureDetaults];
    }
    return self;
}

- (void) awakeFromNib 
{
	[super awakeFromNib];
    [self configureDetaults];
}


#pragma mark - Styling 

@synthesize borderColor;

- (void) setBorderColor:(UIColor *)color 
{
    [borderColor release];
    borderColor = [color retain];
    [self updateLayerAppearanceToMatchContainerView];
}

@synthesize borderWidth;

- (void) setBorderWidth:(CGFloat)width 
{
    if (borderWidth != width) {
        borderWidth = width;
        [self updateLayerAppearanceToMatchContainerView];
    }
}

@synthesize cornerRadius;

- (void) setCornerRadius:(CGFloat)radius 
{
    if (cornerRadius != radius) {
        cornerRadius = radius;
        [self updateLayerAppearanceToMatchContainerView];
    }
}

@synthesize fillColor;

- (void) setFillColor:(UIColor *)color 
{
    [fillColor release];
    fillColor = [[color copy] retain];
    [self updateLayerAppearanceToMatchContainerView];
}


#pragma mark - Selection State

@synthesize showingSelected;

- (void) setShowingSelected:(BOOL)newShowingSelected 
{
    if (showingSelected != newShowingSelected) {
        showingSelected = newShowingSelected;
        [self updateLayerAppearanceToMatchContainerView];
    }
}


#pragma mark - Resource Management

- (void) dealloc 
{
    [borderColor release];
    [fillColor release];
	
    [super dealloc];
}

@end
