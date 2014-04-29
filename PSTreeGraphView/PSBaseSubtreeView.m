//
//  PSBaseSubtreeView.m
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


#import "PSBaseSubtreeView.h"
#import "PSBaseBranchView.h"
#import "PSBaseTreeGraphView.h"


// for CALayer definition
#import <QuartzCore/QuartzCore.h>


#define CENTER_COLLAPSED_SUBTREE_ROOT   1

static UIColor *subtreeBorderColor(void)
{
    return [UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f];
}

static CGFloat subtreeBorderWidth(void)
{
    return 2.0f;
}


#pragma mark - Internal Interface

@interface PSBaseSubtreeView ()
{
    
@private
    
    // the view that shows connections from nodeView to its child nodes
    PSBaseBranchView *_connectorsView;
}


@end


@implementation PSBaseSubtreeView


#pragma mark - Attributes

- (void) setExpanded:(BOOL)flag
{
    if (_expanded != flag) {

        // Remember this SubtreeView's new state.
        _expanded = flag;

        // Notify the TreeGraph we need layout.
        [[self enclosingTreeGraph] setNeedsGraphLayout];

        // Expand or collapse subtrees recursively.
        for (UIView *subview in [self subviews]) {
            if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
                [(PSBaseSubtreeView *)subview setExpanded:_expanded];
            }
        }
    }
}

- (IBAction) toggleExpansion:(id)sender
{
	[UIView beginAnimations:@"TreeNodeExpansion" context:nil];
//    [UIView setAnimationDuration:8.0];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

    [self setExpanded:![self isExpanded]];

    [[self enclosingTreeGraph] layoutGraphIfNeeded];

    if ( [self modelNode] != nil ) {
        NSSet *visibleSet = [NSSet setWithObject:[self modelNode]];
        [[self enclosingTreeGraph] scrollModelNodesToVisible:visibleSet animated:NO];
    }

    [UIView commitAnimations];
}

- (BOOL) isLeaf
{
    return [[[self modelNode] childModelNodes] count] == 0;
}


#pragma mark - Instance Initialization

- initWithModelNode:(id <PSTreeGraphModelNode> )newModelNode
{
    NSParameterAssert(newModelNode);

    self = [super initWithFrame:CGRectMake(10.0, 10.0, 100.0, 25.0)];
    if (self) {

        // Initialize ivars directly.  As a rule, it's best to avoid invoking accessors from an -init...
		// method, since they may wrongly expect the instance to be fully formed.

        _expanded = YES;
        _needsGraphLayout = YES;

        // autoresizesSubviews defaults to YES.  We don't want autoresizing, which would interfere
		// with the explicit layout we do, so we switch it off for SubtreeView instances.
        [self setAutoresizesSubviews:NO];

        self.modelNode = newModelNode;
        _connectorsView = [[PSBaseBranchView alloc] initWithFrame:CGRectZero];
        if (_connectorsView) {
            [_connectorsView setAutoresizesSubviews:YES];
            // if we dont redraw lines, they get out of place
			[_connectorsView setContentMode:UIViewContentModeRedraw];
			[_connectorsView setOpaque:YES];

			[self addSubview:_connectorsView];
        }
    }
    return self;
}


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


#pragma mark - Layout

- (void) recursiveSetNeedsGraphLayout
{
    [self setNeedsGraphLayout:YES];
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
            [(PSBaseSubtreeView *)subview recursiveSetNeedsGraphLayout];
        }
    }
}

- (CGSize) sizeNodeViewToFitContent
{
    // TODO: Node size is hardwired for now, but the layout algorithm could accommodate
    // variable-sized nodes if we implement size-to-fit for nodes.

    return [self.nodeView frame].size;
}

- (void) flipTreeGraph
{
    // Recurse for descendant SubtreeViews.
    CGFloat             myWidth             = self.frame.size.width;
    CGFloat             myHeight            = self.frame.size.height;
    PSBaseTreeGraphView *treeGraph          = [self enclosingTreeGraph];
	PSTreeGraphOrientationStyle treeOrientation = [treeGraph treeGraphOrientation];

    NSArray *subviews = [self subviews];
    for (UIView *subview in subviews) {
        CGPoint             subviewCenter       = subview.center;
        CGPoint             newCenter;
        CGFloat             offset;
        if (treeOrientation == PSTreeGraphOrientationStyleHorizontalFlipped ){
            offset      = subviewCenter.x;
            newCenter   = CGPointMake(myWidth-offset, subviewCenter.y);
        }
        else{
            offset      = subviewCenter.y;
            newCenter   = CGPointMake(subviewCenter.x, myHeight-offset);
        }
        subview.center                          = newCenter;
        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
            [(PSBaseSubtreeView *)subview flipTreeGraph];
        }
    }
}

- (CGSize) layoutGraphIfNeeded
{
    // Return early if layout not needed
    if ( !self.needsGraphLayout )
        return [self frame].size;

    // Do the layout
    CGSize selfTargetSize;
    if ( [self isExpanded] ) {
        selfTargetSize = [self layoutExpandedGraph];
    } else {
        selfTargetSize = [self layoutCollapsedGraph];
    }

    // Mark as having completed layout.
    self.needsGraphLayout = NO;

    // Return our new size.
    return selfTargetSize;
}

- (CGSize) layoutExpandedGraph
{
    CGSize selfTargetSize;

    PSBaseTreeGraphView *treeGraph = [self enclosingTreeGraph];

	CGFloat parentChildSpacing = [treeGraph parentChildSpacing];
    CGFloat siblingSpacing = [treeGraph siblingSpacing];
	PSTreeGraphOrientationStyle treeOrientation = [treeGraph treeGraphOrientation];

    // Size this SubtreeView's nodeView to fit its content.  Our tree layout model assumes the assessment
	// of a node's natural size is a function of intrinsic properties of the node, and isn't influenced
	// by any other nodes or layout in the tree.

    CGSize rootNodeViewSize = [self sizeNodeViewToFitContent];

    // Recurse to lay out each of our child SubtreeViews (and their non-collapsed descendants in turn).
    // Knowing the sizes of our child SubtreeViews will tell us what size this SubtreeView needs to be
    // to contain them (and our nodeView and connectorsView).

    NSArray *subviews = [self subviews];
    NSInteger count = [subviews count];
    NSInteger index;
    NSUInteger subtreeViewCount = 0;
    CGFloat maxWidth = 0.0f;
    CGFloat maxHeight = 0.0f;
    CGPoint nextSubtreeViewOrigin = CGPointZero;

    if (( treeOrientation == PSTreeGraphOrientationStyleHorizontal ) ||
        ( treeOrientation == PSTreeGraphOrientationStyleHorizontalFlipped )){
        nextSubtreeViewOrigin = CGPointMake(rootNodeViewSize.width + parentChildSpacing, 0.0f);
    } else {
        nextSubtreeViewOrigin = CGPointMake(0.0f, rootNodeViewSize.height + parentChildSpacing);
    }

    for (index = count - 1; index >= 0; index--) {
        UIView *subview = subviews[index];

        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
            ++subtreeViewCount;

            // Unhide the view if needed.
            [subview setHidden:NO];

            // Recursively layout the subtree, and obtain the SubtreeView's resultant size.
            CGSize subtreeViewSize = [(PSBaseSubtreeView *)subview layoutGraphIfNeeded];

            // Position the SubtreeView.
            // [(animateLayout ? [subview animator] : subview) setFrameOrigin:nextSubtreeViewOrigin];

            if (( treeOrientation == PSTreeGraphOrientationStyleHorizontal ) || 
                (treeOrientation == PSTreeGraphOrientationStyleHorizontalFlipped )) {
                // Since SubtreeView is unflipped, lay out our child SubtreeViews going upward from our
                // bottom edge, from last to first.
                subview.frame = CGRectMake( nextSubtreeViewOrigin.x,
                                           nextSubtreeViewOrigin.y,
                                           subtreeViewSize.width,
                                           subtreeViewSize.height );

                // Advance nextSubtreeViewOrigin for the next SubtreeView.
                nextSubtreeViewOrigin.y += subtreeViewSize.height + siblingSpacing;

                // Keep track of the widest SubtreeView width we encounter.
                if (maxWidth < subtreeViewSize.width) {
                    maxWidth = subtreeViewSize.width;
                }

            } else {
                // TODO: Lay out our child SubtreeViews going from our left edge, last to first. SWITCH ME
                subview.frame = CGRectMake( nextSubtreeViewOrigin.x,
                                           nextSubtreeViewOrigin.y,
                                           subtreeViewSize.width,
                                           subtreeViewSize.height );

                // Advance nextSubtreeViewOrigin for the next SubtreeView.
                nextSubtreeViewOrigin.x += subtreeViewSize.width + siblingSpacing;

                // Keep track of the widest SubtreeView width we encounter.
                if (maxHeight < subtreeViewSize.height) {
                    maxHeight = subtreeViewSize.height;
                }
            }
        }
    }

    // Calculate the total height of all our SubtreeViews, including the vertical spacing between them.
    // We have N child SubtreeViews, but only (N-1) gaps between them, so subtract 1 increment of
    // siblingSpacing that was added by the loop above.

    CGFloat totalHeight = 0.0f;
    CGFloat totalWidth = 0.0f;

    if (( treeOrientation == PSTreeGraphOrientationStyleHorizontal ) || 
        (treeOrientation == PSTreeGraphOrientationStyleHorizontalFlipped )) {
        totalHeight = nextSubtreeViewOrigin.y;
        if (subtreeViewCount > 0) {
            totalHeight -= siblingSpacing;
        }
    } else {
        totalWidth = nextSubtreeViewOrigin.x;
        if (subtreeViewCount > 0) {
            totalWidth -= siblingSpacing;
        }
    }

    // Size self to contain our nodeView all our child SubtreeViews, and position our
    // nodeView and connectorsView.
    if (subtreeViewCount > 0) {

        // Determine our width and height.
        if (( treeOrientation == PSTreeGraphOrientationStyleHorizontal ) || 
            ( treeOrientation == PSTreeGraphOrientationStyleHorizontalFlipped )) {
            selfTargetSize = CGSizeMake(rootNodeViewSize.width + parentChildSpacing + maxWidth,
                                        MAX(totalHeight, rootNodeViewSize.height) );
        } else {
            selfTargetSize = CGSizeMake(MAX(totalWidth, rootNodeViewSize.width),
                                        rootNodeViewSize.height + parentChildSpacing + maxHeight);
        }

        // Resize to our new width and height.
        // [(animateLayout ? [self animator] : self) setFrameSize:selfTargetSize];
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                selfTargetSize.width,
                                selfTargetSize.height );

        CGPoint nodeViewOrigin = CGPointZero;
        if (( treeOrientation == PSTreeGraphOrientationStyleHorizontal ) ||
            ( treeOrientation == PSTreeGraphOrientationStyleHorizontalFlipped )){
            // Position our nodeView vertically centered along the left edge of our new bounds.
            nodeViewOrigin = CGPointMake(0.0f, 0.5f * (selfTargetSize.height - rootNodeViewSize.height));

        } else {
            // Position our nodeView horizontally centered along the top edge of our new bounds.
            nodeViewOrigin = CGPointMake(0.5f * (selfTargetSize.width - rootNodeViewSize.width), 0.0f);
        }

        // Pixel-align its position to keep its rendering crisp.
        CGPoint windowPoint = [self convertPoint:nodeViewOrigin toView:nil];
        windowPoint.x = round(windowPoint.x);
        windowPoint.y = round(windowPoint.y);
        nodeViewOrigin = [self convertPoint:windowPoint fromView:nil];

        self.nodeView.frame = CGRectMake(nodeViewOrigin.x,
                                         nodeViewOrigin.y,
                                         self.nodeView.frame.size.width,
                                         self.nodeView.frame.size.height );

        // Position, show our connectorsView and button.

        // TODO: Can shrink height a bit on top and bottom ends, since the connecting lines
        // meet at the nodes' vertical centers

        // NOTE: It may be better to stretch the content if a collapse animation is added?
        // Be sure to test.  Given the size, and how they just contain the lines,  it seems
        // best to just redraw these things.

        // [_connectorsView setContentMode:UIViewContentModeScaleToFill ];

        if (( treeOrientation == PSTreeGraphOrientationStyleHorizontal ) ||
            ( treeOrientation == PSTreeGraphOrientationStyleHorizontalFlipped )){
            _connectorsView.frame = CGRectMake(rootNodeViewSize.width,
                                               0.0f,
                                               parentChildSpacing,
                                               selfTargetSize.height );
        } else {
            _connectorsView.frame = CGRectMake(0.0f,
                                               rootNodeViewSize.height,
                                               selfTargetSize.width,
                                               parentChildSpacing );
        }

        // NOTE: Enable this line if a collapse animation is added (line below not used)
        // [_connectorsView setContentMode:UIViewContentModeRedraw];

        [_connectorsView setHidden:NO];

    } else {
        // No SubtreeViews; this is a leaf node.
        // Size self to exactly wrap nodeView, hide connectorsView, and hide the button.

        selfTargetSize = rootNodeViewSize;

        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                selfTargetSize.width,
                                selfTargetSize.height );

        self.nodeView.frame = CGRectMake(0.0f,
                                         0.0f,
                                         self.nodeView.frame.size.width,
                                         self.nodeView.frame.size.height );

        [_connectorsView setHidden:YES];
    }

    // Return our new size.
    return selfTargetSize;
}

- (CGSize) layoutCollapsedGraph
{

    // This node is collapsed. Everything will be collapsed behind the leafNode
    CGSize selfTargetSize = [self sizeNodeViewToFitContent];

    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            selfTargetSize.width,
                            selfTargetSize.height );

    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {

            [(PSBaseSubtreeView *)subview layoutGraphIfNeeded];

            subview.frame = CGRectMake(0.0f,
                                       0.0f,
                                       subview.frame.size.width,
                                       subview.frame.size.height );

            [subview setHidden:YES];

        } else if (subview == _connectorsView) {

            // NOTE: It may be better to stretch the content if a collapse animation is added?
            // Be sure to test.  Given the size, and how they just contain the lines,  it seems
            // best to just redraw these things.

            // [_connectorsView setContentMode:UIViewContentModeScaleToFill ];

            PSTreeGraphOrientationStyle treeOrientation = [[self enclosingTreeGraph] treeGraphOrientation];
            if (( treeOrientation == PSTreeGraphOrientationStyleHorizontal ) || 
                ( treeOrientation == PSTreeGraphOrientationStyleHorizontal )){
                _connectorsView.frame = CGRectMake(0.0f,
                                                   0.5f * selfTargetSize.height,
                                                   0.0f,
                                                   0.0f );
            } else {
                _connectorsView.frame = CGRectMake(0.5f * selfTargetSize.width,
                                                   0.0f,
                                                   0.0f,
                                                   0.0f );
            }

            // NOTE: Enable this line if a collapse animation is added (line below not used)
            // [_connectorsView setContentMode:UIViewContentModeRedraw];

            [subview setHidden:YES];

        } else if (subview == _nodeView) {

            subview.frame = CGRectMake(0.0f,
                                       0.0f,
                                       selfTargetSize.width,
                                       selfTargetSize.height );

        }
    }

    // Return our new size.
    return selfTargetSize;
}


#pragma mark - Drawing

- (void) updateSubtreeBorder
{
    // // Disable implicit animations during these layer property changes, to make them take effect immediately.
    // BOOL actionsWereDisabled = [CATransaction disableActions];
    // [CATransaction setDisableActions:YES];

    // If the enclosing TreeGraph has its "showsSubtreeFrames" debug feature enabled,
    // configure the backing layer to draw its border programmatically.  This is much more efficient
    // than allocating a backing store for each SubtreeView's backing layer, only to stroke a simple
    // rectangle into that backing store.
    
    CALayer *layer = [self layer];

    PSBaseTreeGraphView *treeGraph = [self enclosingTreeGraph];
    
    if ([treeGraph showsSubtreeFrames]) {
        [layer setBorderWidth:subtreeBorderWidth()];
        [layer setBorderColor:[subtreeBorderColor() CGColor]];
    } else {
        [layer setBorderWidth:0.0];
    }

    // // Disable implicit animations during these layer property changes
    // [CATransaction setDisableActions:actionsWereDisabled];

}


#pragma mark - Invalidation

- (void) recursiveSetConnectorsViewsNeedDisplay
{
    // Mark this SubtreeView's connectorsView as needing display.
    [_connectorsView setNeedsDisplay];

    // Recurse for descendant SubtreeViews.
    NSArray *subviews = [self subviews];
    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
            [(PSBaseSubtreeView *)subview recursiveSetConnectorsViewsNeedDisplay];
        }
    }
}

- (void) resursiveSetSubtreeBordersNeedDisplay
{
    // We only need this if layer-backed.  When we have a backing layer, we use the
    // layer's "border" properties to draw the subtree debug border.

    [self updateSubtreeBorder];

    // Recurse for descendant SubtreeViews.
    NSArray *subviews = [self subviews];
    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
            [(PSBaseSubtreeView *)subview updateSubtreeBorder];
        }
    }
}


#pragma mark - Selection State

- (BOOL) nodeIsSelected
{
    return [[[self enclosingTreeGraph] selectedModelNodes] containsObject:[self modelNode]];
}


#pragma mark - Node Hit-Testing

- (id <PSTreeGraphModelNode> ) modelNodeAtPoint:(CGPoint)p
{
	// Check for intersection with our subviews, enumerating them in reverse order to get
	// front-to-back ordering.  We could use UIView's -hitTest: method here, but we don't
	// want to bother hit-testing deeper than the nodeView level.

    NSArray *subviews = [self subviews];
    NSInteger count = [subviews count];
    NSInteger index;

    for (index = count - 1; index >= 0; index--) {
        UIView *subview = subviews[index];

		//        CGRect subviewBounds = [subview bounds];
        CGPoint subviewPoint = [subview convertPoint:p fromView:self];
		//
		//		  if (CGPointInRect(subviewPoint, subviewBounds)) {

		if ( [subview pointInside:subviewPoint withEvent:nil]  ) {

            if (subview == [self nodeView]) {
                return [self modelNode];
            } else if ( [subview isKindOfClass:[PSBaseSubtreeView class]] ) {
                return [(PSBaseSubtreeView *)subview modelNodeAtPoint:subviewPoint];
            } else {
                // Ignore subview. It's probably a BranchView.
            }
        }
    }

    // We didn't find a hit.
    return nil;
}

- (id <PSTreeGraphModelNode> ) modelNodeClosestToY:(CGFloat)y
{
	// Do a simple linear search of our subviews, ignoring non-SubtreeViews.  If performance was ever
    // an issue for this code, we could take advantage of knowing the layout order of the nodes to do
    // a sort of binary search.

    NSArray *subviews = [self subviews];
    PSBaseSubtreeView *subtreeViewWithClosestNodeView = nil;
    CGFloat closestNodeViewDistance = MAXFLOAT;

    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
            UIView *childNodeView = [(PSBaseSubtreeView *)subview nodeView];
            if (childNodeView) {
                CGRect rect = [self convertRect:[childNodeView bounds] fromView:childNodeView];
                CGFloat nodeViewDistance = fabs(y - CGRectGetMidY(rect));
                if (nodeViewDistance < closestNodeViewDistance) {
                    closestNodeViewDistance = nodeViewDistance;
                    subtreeViewWithClosestNodeView = (PSBaseSubtreeView *)subview;
                }
            }
        }
    }

    return [subtreeViewWithClosestNodeView modelNode];
}

- (id <PSTreeGraphModelNode> ) modelNodeClosestToX:(CGFloat)x
{
	// Do a simple linear search of our subviews, ignoring non-SubtreeViews.  If performance was ever
    // an issue for this code, we could take advantage of knowing the layout order of the nodes to do
    // a sort of binary search.

    NSArray *subviews = [self subviews];
    PSBaseSubtreeView *subtreeViewWithClosestNodeView = nil;
    CGFloat closestNodeViewDistance = MAXFLOAT;

    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
            UIView *childNodeView = [(PSBaseSubtreeView *)subview nodeView];
            if (childNodeView) {
                CGRect rect = [self convertRect:[childNodeView bounds] fromView:childNodeView];
                CGFloat nodeViewDistance = fabs(x - CGRectGetMidX(rect));
                if (nodeViewDistance < closestNodeViewDistance) {
                    closestNodeViewDistance = nodeViewDistance;
                    subtreeViewWithClosestNodeView = (PSBaseSubtreeView *)subview;
                }
            }
        }
    }

    return [subtreeViewWithClosestNodeView modelNode];
}


#pragma mark - Debugging

// These methods access private member variables so they do not invoke app logic.  We only
// want to dump the current state.  Change this if these properties are synthesized.

- (NSString *) description
{
    return [NSString stringWithFormat:@"SubtreeView<%@>", [_modelNode description]];
}

- (NSString *) nodeSummary
{
    return [NSString stringWithFormat:@"f=%@ %@", NSStringFromCGRect([_nodeView frame]), [_modelNode description]];
}

- (NSString *) treeSummaryWithDepth:(NSInteger)depth
{
    NSEnumerator *subviewsEnumerator = [[self subviews] objectEnumerator];
    UIView *subview;
    NSMutableString *description = [NSMutableString string];
    NSInteger i;
    for (i = 0; i < depth; i++) {
        [description appendString:@"  "];
    }
    [description appendFormat:@"%@\n", [self nodeSummary]];
    while (subview = [subviewsEnumerator nextObject]) {
        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
            [description appendString:[(PSBaseSubtreeView *)subview treeSummaryWithDepth:(depth + 1)]];
        }
    }
    return description;
}


@end
