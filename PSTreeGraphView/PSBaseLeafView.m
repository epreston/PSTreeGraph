//
//  PSBaseLeafView.m
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


#import "PSBaseLeafView.h"


// for CALayer definition
#import <QuartzCore/QuartzCore.h>



@interface PSBaseLeafView ()

- (void) updateLayerAppearanceToMatchContainerView;
- (void) configureDetaults;

@end


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
		
        [layer setBorderWidth:(borderWidth_ * scaleFactor)];
        if (borderWidth_ > 0.0f) {
            [layer setBorderColor:[borderColor_ CGColor]];
        }
		
        [layer setCornerRadius:(cornerRadius_ * scaleFactor)];
		
		if ( showingSelected_ ) {
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
	
	borderColor_ = [[UIColor colorWithRed:1.0f green:0.8f blue:0.4f alpha:1.0f] retain];
	borderWidth_ = 3.0f;
	cornerRadius_ = 8.0f;
	fillColor_ = [[UIColor colorWithRed:1.0f green:0.5f blue:0.0f alpha:1.0f] retain];
    showingSelected_ = NO;
	
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


#pragma mark - Resource Management

- (void) dealloc 
{
    [borderColor_ release];
    [fillColor_ release];
	
    [super dealloc];
}


#pragma mark - Styling 

@synthesize borderColor = borderColor_;

- (void) setBorderColor:(UIColor *)color 
{
    if (borderColor_ != color) {
        [borderColor_ release];
        borderColor_ = [color retain];
        [self updateLayerAppearanceToMatchContainerView];
    }
}

@synthesize borderWidth = borderWidth_;

- (void) setBorderWidth:(CGFloat)width 
{
    if (borderWidth_ != width) {
        borderWidth_ = width;
        [self updateLayerAppearanceToMatchContainerView];
    }
}

@synthesize cornerRadius = cornerRadius_;

- (void) setCornerRadius:(CGFloat)radius 
{
    if (cornerRadius_ != radius) {
        cornerRadius_ = radius;
        [self updateLayerAppearanceToMatchContainerView];
    }
}

@synthesize fillColor = fillColor_;

- (void) setFillColor:(UIColor *)color 
{
    if (fillColor_ != color) {
        [fillColor_ release];
        fillColor_ = [color retain];
        [self updateLayerAppearanceToMatchContainerView];
    }
}


#pragma mark - Selection State

@synthesize showingSelected = showingSelected_;

- (void) setShowingSelected:(BOOL)newShowingSelected 
{
    if (showingSelected_ != newShowingSelected) {
        showingSelected_ = newShowingSelected;
        [self updateLayerAppearanceToMatchContainerView];
    }
}


@end
