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


#pragma mark - Internal Interface

@interface PSBaseLeafView ()
{
    
@private
    UIColor    *borderColor_;
    CGFloat     borderWidth_;
    CGFloat     cornerRadius_;
    
    UIColor    *fillColor_;
    UIColor    *selectionColor_;
    
    BOOL        showingSelected_;
}

- (void) updateLayerAppearanceToMatchContainerView;
- (void) configureDetaults;

@end


@implementation PSBaseLeafView


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

@synthesize selectionColor = selectionColor_;

- (void) setSelectionColor:(UIColor *)color
{
    if (selectionColor_ != color) {
        [selectionColor_ release];
        selectionColor_ = [color retain];
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


#pragma mark - Update Layer

- (void) updateLayerAppearanceToMatchContainerView
{
    // // Disable implicit animations during these layer property changes, to make them take effect immediately.

    // BOOL actionsWereDisabled = [CATransaction disableActions];
    // [CATransaction setDisableActions:YES];

    // Apply the ContainerView's appearance properties to its backing layer.
    // Important: While UIView metrics are conventionally expressed in points, CALayer metrics are
    // expressed in pixels.  To produce the correct borderWidth and cornerRadius to apply to the
    // layer, we must multiply by the window's userSpaceScaleFactor (which is normally 1.0, but may
    // be larger on a higher-resolution display) to yield pixel units.

    // CGFloat scaleFactor = [[self window] userSpaceScaleFactor];
    CGFloat scaleFactor = 1.0f;
    
    CALayer *layer = [self layer];

    [layer setBorderWidth:(borderWidth_ * scaleFactor)];
    if (borderWidth_ > 0.0f) {
        [layer setBorderColor:[borderColor_ CGColor]];
    }

    [layer setCornerRadius:(cornerRadius_ * scaleFactor)];

    if ( showingSelected_ ) {
        [layer setBackgroundColor:[[self selectionColor] CGColor] ];
    } else {
        [layer setBackgroundColor:[[self fillColor] CGColor] ];
    }

    // // Disable implicit animations during these layer property changes
    // [CATransaction setDisableActions:actionsWereDisabled];
}


#pragma mark - Initialization

- (void) configureDetaults
{
	// Initialize ivars directly.  As a rule, it's best to avoid invoking accessors from an -init...
	// method, since they may wrongly expect the instance to be fully formed.

	borderColor_ = [[UIColor colorWithRed:1.0 green:0.8 blue:0.4 alpha:1.0] retain];
	borderWidth_ = 3.0;
	cornerRadius_ = 8.0;
	fillColor_ = [[UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0] retain];
    selectionColor_ = [[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0] retain];
    showingSelected_ = NO;
}


#pragma mark - Resource Management

- (void) dealloc
{
    [borderColor_ release];
    [fillColor_ release];
    [selectionColor_ release];

    [super dealloc];
}


#pragma mark - UIView

- initWithFrame:(CGRect)newFrame
{
    self = [super initWithFrame:newFrame];
    if (self) {
		[self configureDetaults];
        [self updateLayerAppearanceToMatchContainerView];
    }
    return self;
}


#pragma mark - NSCoding

- (void) encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:borderColor_ forKey:@"borderColor"];
    [encoder encodeFloat:borderWidth_ forKey:@"borderWidth"];
    [encoder encodeFloat:cornerRadius_ forKey:@"cornerRadius"];
    [encoder encodeObject:fillColor_ forKey:@"fillColor"];
    [encoder encodeObject:selectionColor_ forKey:@"selectionColor"];
    [encoder encodeBool:showingSelected_ forKey:@"showingSelected"];
}

- (id) initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {

        [self configureDetaults];

        if ([decoder containsValueForKey:@"borderColor"])
            borderColor_ = [[decoder decodeObjectForKey:@"borderColor"] retain];
        if ([decoder containsValueForKey:@"borderWidth"])
            borderWidth_ = [decoder decodeFloatForKey:@"borderWidth"];
        if ([decoder containsValueForKey:@"cornerRadius"])
            cornerRadius_ = [decoder decodeFloatForKey:@"cornerRadius"];
        if ([decoder containsValueForKey:@"fillColor"])
            fillColor_ = [[decoder decodeObjectForKey:@"fillColor"] retain];
        if ([decoder containsValueForKey:@"selectionColor"])
            selectionColor_ = [[decoder decodeObjectForKey:@"selectionColor"] retain];
        if ([decoder containsValueForKey:@"showingSelected"])
            showingSelected_ = [decoder decodeBoolForKey:@"showingSelected"];

        [self updateLayerAppearanceToMatchContainerView];
    }
    return self;
}


@end
