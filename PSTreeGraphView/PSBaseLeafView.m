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

- (void)updateLayerAppearanceToMatchContainerView {
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
		CGFloat scaleFactor = 1.0;
		
        [layer setBorderWidth:(borderWidth * scaleFactor)];
        if (borderWidth > 0.0) {
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

- (void)configureDetaults {
	// Initialize ivars directly.  As a rule, it's best to avoid invoking accessors from an -init...
	// method, since they may wrongly expect the instance to be fully formed.
	
	borderColor = [[UIColor colorWithRed:1.0 green:0.8 blue:0.4 alpha:1.0] retain];
	borderWidth = 3.0;
	cornerRadius = 8.0;
	fillColor = [[UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0] retain];
	
	[self updateLayerAppearanceToMatchContainerView];
}

- initWithFrame:(CGRect)newFrame {
    self = [super initWithFrame:newFrame];
    if (self) {
		[self configureDetaults];
        // [self setLayerContentsRedrawPolicy:UIViewLayerContentsRedrawNever];
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
    [self configureDetaults];
}


#pragma mark - Drawing

// Since we set each ContainerView's layerContentsRedrawPolicy to UIViewLayerContentsRedrawNever,
// this -drawRect: method will only be invoked if the ContainerView is window-backed.  If the
// ContainerView is layer-backed, the layer's appearance properties, as configured in
// -updateLayerAppearanceToMatchContainerView above, provide this drawing for us.
 
//- (void)drawRect:(CGRect)rect {
//    float halfBorderWidth = 0.5 * [self borderWidth];
//    CGRect borderRect = CGRectInset([self bounds], halfBorderWidth, halfBorderWidth);
//    CGFloat effectiveRadius = MAX(0.0, [self cornerRadius] - halfBorderWidth); 
//	
//	// CALayer's cornerRadius applies to its overall shape, with its border (if any) extending
//	// for borderWidth pixels from there.  A srtroked UIBezierPath extends by half the path's 
//	// line width to either side of the ideal path.  To produce rendered results that closely 
//	// match those in layer-backed mode, since ContainerView is optimized to leverage CALayer's 
//	// programmatic drawing capabilities when layer-backed, we need to inset the path we're going
//	// to stroke by half the border width.
//    
//	UIBezierPath *borderStrokePath = [UIBezierPath bezierPathWithRoundedRect:borderRect cornerRadius:effectiveRadius];
//	
//    // Fill background.
//    [(showingSelected ? [UIColor yellowColor] : [self fillColor]) set];
//    [borderStrokePath fill];
//	
//    // Stroke border.
//    if (halfBorderWidth > 0.0) {
//        [borderStrokePath setLineWidth:[self borderWidth]];
//        [[self borderColor] set];
//        [borderStrokePath stroke];
//    }
//}


#pragma mark - Styling 

- (UIColor *)borderColor {
    return borderColor;
}

- (void)setBorderColor:(UIColor *)color {
    if (borderColor != color) {
        [borderColor release];
        borderColor = [[color copy] retain];
        [self updateLayerAppearanceToMatchContainerView];
    }
}

- (float)borderWidth {
    return borderWidth;
}

- (void)setBorderWidth:(float)width {
    if (borderWidth != width) {
        borderWidth = width;
        [self updateLayerAppearanceToMatchContainerView];
    }
}

- (float)cornerRadius {
    return cornerRadius;
}

- (void)setCornerRadius:(float)radius {
    if (cornerRadius != radius) {
        cornerRadius = radius;
        [self updateLayerAppearanceToMatchContainerView];
    }
}

- (UIColor *)fillColor {
    return fillColor;
}

- (void)setFillColor:(UIColor *)color {
    if (fillColor != color) {
        [fillColor release];
        fillColor = [[color copy] retain];
        [self updateLayerAppearanceToMatchContainerView];
    }
}


#pragma mark - Selection State

- (BOOL)showingSelected {
    return showingSelected;
}

- (void)setShowingSelected:(BOOL)newShowingSelected {
    if (showingSelected != newShowingSelected) {
        showingSelected = newShowingSelected;
        [self updateLayerAppearanceToMatchContainerView];
    }
}


#pragma mark - Memory Management

- (void)dealloc {
    [borderColor release];
    [fillColor release];
	
    [super dealloc];
}

@end
