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


@implementation PSBaseLeafView


#pragma mark - Styling


- (void) setBorderColor:(UIColor *)color
{
    if (_borderColor != color) {
        _borderColor = color;
        [self updateLayerAppearanceToMatchContainerView];
    }
}

- (void) setBorderWidth:(CGFloat)width
{
    if (_borderWidth != width) {
        _borderWidth = width;
        [self updateLayerAppearanceToMatchContainerView];
    }
}

- (void) setCornerRadius:(CGFloat)radius
{
    if (_cornerRadius != radius) {
        _cornerRadius = radius;
        [self updateLayerAppearanceToMatchContainerView];
    }
}

- (void) setFillColor:(UIColor *)color
{
    if (_fillColor != color) {
        _fillColor = color;
        [self updateLayerAppearanceToMatchContainerView];
    }
}

- (void) setSelectionColor:(UIColor *)color
{
    if (_selectionColor != color) {
        _selectionColor = color;
        [self updateLayerAppearanceToMatchContainerView];
    }
}


#pragma mark - Selection State

- (void) setShowingSelected:(BOOL)newShowingSelected
{
    if (_showingSelected != newShowingSelected) {
        _showingSelected = newShowingSelected;
        [self updateLayerAppearanceToMatchContainerView];
    }
}


#pragma mark - Update Layer (internal)

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

    [layer setBorderWidth:(_borderWidth * scaleFactor)];
    if (_borderWidth > 0.0f) {
        [layer setBorderColor:[_borderColor CGColor]];
    }

    [layer setCornerRadius:(_cornerRadius * scaleFactor)];

    if ( _showingSelected ) {
        [layer setBackgroundColor:[[self selectionColor] CGColor] ];
    } else {
        [layer setBackgroundColor:[[self fillColor] CGColor] ];
    }

    // // Disable implicit animations during these layer property changes
    // [CATransaction setDisableActions:actionsWereDisabled];
}


#pragma mark - Initialization (internal)

- (void) configureDetaults
{
	// Initialize ivars directly.  As a rule, it's best to avoid invoking accessors from an -init...
	// method, since they may wrongly expect the instance to be fully formed.

	_borderColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.4 alpha:1.0];
	_borderWidth = 3.0;
	_cornerRadius = 8.0;
	_fillColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0];
    _selectionColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
    _showingSelected = NO;
}


#pragma mark - UIView

- (instancetype) initWithFrame:(CGRect)newFrame
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
    [encoder encodeObject:_borderColor forKey:@"borderColor"];
    [encoder encodeFloat:_borderWidth forKey:@"borderWidth"];
    [encoder encodeFloat:_cornerRadius forKey:@"cornerRadius"];
    [encoder encodeObject:_fillColor forKey:@"fillColor"];
    [encoder encodeObject:_selectionColor forKey:@"selectionColor"];
    [encoder encodeBool:_showingSelected forKey:@"showingSelected"];
}

- (id) initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {

        [self configureDetaults];

        if ([decoder containsValueForKey:@"borderColor"])
            _borderColor = [decoder decodeObjectForKey:@"borderColor"];
        if ([decoder containsValueForKey:@"borderWidth"])
            _borderWidth = [decoder decodeFloatForKey:@"borderWidth"];
        if ([decoder containsValueForKey:@"cornerRadius"])
            _cornerRadius = [decoder decodeFloatForKey:@"cornerRadius"];
        if ([decoder containsValueForKey:@"fillColor"])
            _fillColor = [decoder decodeObjectForKey:@"fillColor"];
        if ([decoder containsValueForKey:@"selectionColor"])
            _selectionColor = [decoder decodeObjectForKey:@"selectionColor"];
        if ([decoder containsValueForKey:@"showingSelected"])
            _showingSelected = [decoder decodeBoolForKey:@"showingSelected"];

        [self updateLayerAppearanceToMatchContainerView];
    }
    return self;
}


@end
