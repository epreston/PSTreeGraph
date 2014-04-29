//
//  PSBaseBranchView.m
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


#import "PSBaseBranchView.h"
#import "PSBaseSubtreeView.h"
#import "PSBaseTreeGraphView.h"


@implementation PSBaseBranchView


- (PSBaseTreeGraphView *) enclosingTreeGraph
{
    UIView *ancestor = [self superview];
    while (ancestor) {
        if ([ancestor isKindOfClass:[PSBaseTreeGraphView class]]) {
            return (PSBaseTreeGraphView *)ancestor;
        }
        ancestor = [ancestor superview];
    }
    return nil;
}


#pragma mark - Drawing (internal)

- (UIBezierPath *) directConnectionsPath
{
    CGRect bounds = [self bounds];
	CGPoint rootPoint = CGPointZero;

	PSTreeGraphOrientationStyle treeDirection = [[self enclosingTreeGraph] treeGraphOrientation];

	if (( treeDirection == PSTreeGraphOrientationStyleHorizontal ) ||
        ( treeDirection == PSTreeGraphOrientationStyleHorizontalFlipped )){
		rootPoint = CGPointMake(CGRectGetMinX(bounds),
                                CGRectGetMidY(bounds));
	} else {
		rootPoint = CGPointMake(CGRectGetMidX(bounds),
                                CGRectGetMinY(bounds));
	}

    // Create a single bezier path that we'll use to stroke all the lines.
    UIBezierPath *path = [UIBezierPath bezierPath];

    // Add a stroke from rootPoint to each child SubtreeView of our containing SubtreeView.
    UIView *subtreeView = [self superview];
    if ([subtreeView isKindOfClass:[PSBaseSubtreeView class]]) {

        for (UIView *subview in [subtreeView subviews]) {
            if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
                CGRect subviewBounds = [subview bounds];
				CGPoint targetPoint = CGPointZero;

                if (( treeDirection == PSTreeGraphOrientationStyleHorizontal ) ||
                    ( treeDirection == PSTreeGraphOrientationStyleHorizontalFlipped )){
					targetPoint = [self convertPoint:CGPointMake(CGRectGetMinX(subviewBounds), CGRectGetMidY(subviewBounds))
                                            fromView:subview];
				} else {
					targetPoint = [self convertPoint:CGPointMake(CGRectGetMidX(subviewBounds), CGRectGetMinY(subviewBounds))
                                            fromView:subview];
				}

                [path moveToPoint:rootPoint];
                [path addLineToPoint:targetPoint];
            }
        }
    }

    // Return the path.
    return path;
}

- (UIBezierPath *) orthogonalConnectionsPath
{
    // Compute the needed adjustment in x and y to align our lines for crisp, exact pixel coverage.
	// (We can only do this if the lineWidth is integral, which it usually is.)
	//    CGFloat adjustment = 0.0;
	//    CGFloat lineWidth = [[self enclosingTreeGraph] connectingLineWidth];
	//    CGSize lineSize = CGSizeMake(lineWidth, lineWidth);
	//    CGSize lineSizeInPixels = [self convertSizeToBase:lineSize];
	//
	//    CGFloat halfLineWidthInPixels = 0.5 * lineSizeInPixels.width;
	//    if (fabs(halfLineWidthInPixels - floor(halfLineWidthInPixels)) > 0.0001) {
	//        // If line width in pixels is odd, lay our path segments along the centers of pixel rows.
	//        CGSize adjustmentAsSizeInPixels = CGSizeMake(0.5, 0.5);
	//        CGSize adjustmentAsSize = [self convertSizeFromBase:adjustmentAsSizeInPixels];
	//
	//        adjustment = adjustmentAsSize.width;
	//    }

    CGRect bounds = [self bounds];
	//    CGPoint basePoint;

	PSTreeGraphOrientationStyle treeDirection = [[self enclosingTreeGraph] treeGraphOrientation];

	CGPoint rootPoint = CGPointZero;
	if ( treeDirection == PSTreeGraphOrientationStyleHorizontal ) {
		// Compute point at right edge of root node, from which its connecting line to the vertical line will emerge.
		rootPoint = CGPointMake(CGRectGetMinX(bounds),
                                CGRectGetMidY(bounds));
	} else if ( treeDirection == PSTreeGraphOrientationStyleHorizontalFlipped ){
		// Compute point at left edge of root node, from which its connecting line to the vertical line will emerge.
		rootPoint = CGPointMake(CGRectGetMaxX(bounds),
                                CGRectGetMidY(bounds));
	} else if ( treeDirection == PSTreeGraphOrientationStyleVerticalFlipped ){
		// Compute point at top edge of root node, from which its connecting line to the vertical line will emerge.
		rootPoint = CGPointMake(CGRectGetMidX(bounds),
                                CGRectGetMaxY(bounds));
	} else {
		rootPoint = CGPointMake(CGRectGetMidX(bounds),
                                CGRectGetMinY(bounds));
	}


    // Align the line to get exact pixel coverage, for sharper rendering.
	//    basePoint = [self convertPointToBase:rootPoint];
	//    basePoint.x = round(basePoint.x) + adjustment;
	//    basePoint.y = round(basePoint.y) + adjustment;
	//    rootPoint = [self convertPointFromBase:basePoint];


	// Compute point (really, we're just interested in the x value) at which line
    // from root node intersects the vertical connecting line.

	CGPoint rootIntersection = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));


    // Align the line to get exact pixel coverage, for sharper rendering.
	//    basePoint = [self convertPointToBase:rootIntersection];
	//    basePoint.x = round(basePoint.x) + adjustment;
	//    basePoint.y = round(basePoint.y) + adjustment;
	//    rootIntersection = [self convertPointFromBase:basePoint];

    // Create a single bezier path that we'll use to stroke all the lines.
    UIBezierPath *path = [UIBezierPath bezierPath];

    // Add a stroke from each child SubtreeView to where we'll put the vertical connecting line.
    // And while we're iterating over SubtreeViews, make a note of the minimum and maximum Y we'll
    // want for the endpoints of the vertical connecting line.

    CGFloat minY = rootPoint.y;
    CGFloat maxY = rootPoint.y;
	CGFloat minX = rootPoint.x;
    CGFloat maxX = rootPoint.x;

    UIView *subtreeView = [self superview];
    NSInteger subtreeViewCount = 0;

    if ([subtreeView isKindOfClass:[PSBaseSubtreeView class]]) {

        for (UIView *subview in [subtreeView subviews]) {
            if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
                ++subtreeViewCount;

                CGRect subviewBounds = [subview bounds];
				CGPoint targetPoint = CGPointZero;

                if (( treeDirection == PSTreeGraphOrientationStyleHorizontal ) ||
                    ( treeDirection == PSTreeGraphOrientationStyleHorizontalFlipped )){
					targetPoint = [self convertPoint:CGPointMake(CGRectGetMinX(subviewBounds), CGRectGetMidY(subviewBounds))
                                            fromView:subview];
				} else {
					targetPoint = [self convertPoint:CGPointMake(CGRectGetMidX(subviewBounds), CGRectGetMinY(subviewBounds))
                                            fromView:subview];
				}

                // Align the line to get exact pixel coverage, for sharper rendering.
				//                basePoint = [self convertPointToBase:targetPoint];
				//                basePoint.x = round(basePoint.x) + adjustment;
				//                basePoint.y = round(basePoint.y) + adjustment;
				//                targetPoint = [self convertPointFromBase:basePoint];

                // TODO: Make clean line joins (test at high values of line thickness to see the problem).

                if (( treeDirection == PSTreeGraphOrientationStyleHorizontal ) ||
                    ( treeDirection == PSTreeGraphOrientationStyleHorizontalFlipped )){
					[path moveToPoint:CGPointMake(rootIntersection.x, targetPoint.y)];

					if (minY > targetPoint.y) {
						minY = targetPoint.y;
					}
					if (maxY < targetPoint.y) {
						maxY = targetPoint.y;
					}
				} else {
					[path moveToPoint:CGPointMake(targetPoint.x, rootIntersection.y)];

					if (minX > targetPoint.x) {
						minX = targetPoint.x;
					}
					if (maxX < targetPoint.x) {
						maxX = targetPoint.x;
					}
				}

                [path addLineToPoint:targetPoint];

            }
        }
    }

    if (subtreeViewCount) {
        // Add a stroke from rootPoint to where we'll put the vertical connecting line.
        [path moveToPoint:rootPoint];
        [path addLineToPoint:rootIntersection];

        if (( treeDirection == PSTreeGraphOrientationStyleHorizontal ) ||
            ( treeDirection == PSTreeGraphOrientationStyleHorizontalFlipped )){
			// Add a stroke for the vertical connecting line.
			[path moveToPoint:CGPointMake(rootIntersection.x, minY)];
			[path addLineToPoint:CGPointMake(rootIntersection.x, maxY)];
		} else {
			// Add a stroke for the vertical connecting line.
			[path moveToPoint:CGPointMake(minX, rootIntersection.y)];
			[path addLineToPoint:CGPointMake(maxX, rootIntersection.y)];
		}

    }

    // Return the path.
    return path;
}


#pragma mark - UIView

- (void) drawRect:(CGRect)dirtyRect
{
    // Build the set of lines to stroke, according to our enclosingTreeGraph's connectingLineStyle.
    UIBezierPath *path = nil;

    switch ([[self enclosingTreeGraph] connectingLineStyle]) {
        case PSTreeGraphConnectingLineStyleDirect:
        default:
            path = [self directConnectionsPath];
            break;

        case PSTreeGraphConnectingLineStyleOrthogonal:
            path = [self orthogonalConnectionsPath];
            break;
    }

    // Stroke the path with the appropriate color and line width.
    PSBaseTreeGraphView *treeGraph = [self enclosingTreeGraph];

	if ( [self isOpaque] ) {
		// Fill background.
		[[treeGraph backgroundColor] set];
		UIRectFill(dirtyRect);
	}

	// Draw lines
	[[treeGraph connectingLineColor] set];
	[path setLineWidth:[treeGraph connectingLineWidth]];
	[path stroke];
}


@end
