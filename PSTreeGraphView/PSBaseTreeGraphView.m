//
//  PSBaseTreeGraphView.m
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

#import "PSBaseTreeGraphView.h"
#import "PSBaseTreeGraphView_Internal.h"
#import "PSBaseSubtreeView.h"
#import "PSBaseLeafView.h"

#import "PSTreeGraphDelegate.h"
#import "PSTreeGraphModelNode.h"

// For displayIfNeeded
#import <QuartzCore/QuartzCore.h>


#pragma mark - Internal Interface

@interface PSBaseTreeGraphView () 
{
    
@private
	// Model
    id <PSTreeGraphModelNode> modelRoot_;
    
	// Delegate
	id <PSTreeGraphDelegate> delegate_;
    
    // Model Object -> SubtreeView Mapping
	NSMutableDictionary *modelNodeToSubtreeViewMapTable_;
    
    // Selection State
    NSSet *selectedModelNodes_;
    
    // Layout State
    CGSize minimumFrameSize_;
    
    // Animation Support
    BOOL animatesLayout_;
    BOOL layoutAnimationSuppressed_;
    
    // Layout Metrics
    CGFloat contentMargin_;
    CGFloat parentChildSpacing_;
    CGFloat siblingSpacing_;
    
    // Layout Behavior
    BOOL resizesToFillEnclosingScrollView_;
	PSTreeGraphOrientationStyle treeGraphOrientation_;
    BOOL treeGraphFlipped_;
    
    // Styling
    // UIColor *backgroundColor;
    
    UIColor *connectingLineColor_;
    CGFloat connectingLineWidth_;
    PSTreeGraphConnectingLineStyle connectingLineStyle_;
    
    // A debug feature that outlines the view hiarchy.
    BOOL showsSubtreeFrames_;
    
    // Node View Nib Specification
    NSString *nodeViewNibName_;
    
	// iOS 4 and above ONLY
    UINib *cachedNodeViewNib_;
    
    // Custom input view support
    UIView *inputView_;
}

- (void) configureDefaults;
- (PSBaseSubtreeView *) newGraphForModelNode:(id <PSTreeGraphModelNode> )modelNode;
- (void) buildGraph;
- (void) updateFrameSizeForContentAndClipView;
- (void) updateRootSubtreeViewPositionForSize:(CGSize)rootSubtreeViewSize;

@end


@implementation PSBaseTreeGraphView

@synthesize delegate = delegate_;
@synthesize layoutAnimationSuppressed = layoutAnimationSuppressed_;
@synthesize minimumFrameSize = minimumFrameSize_;

#pragma mark - Styling

// Getters and setters for TreeGraph's appearance-related properties: colors, metrics, etc.  We could almost
// auto-generate these using "@synthesize", but we want each setter to automatically mark the affected parts
// of the TreeGraph (and/or the descendant views that it's responsible for) as needing drawing to reflet the
// appearance change.  In other respects, these are unremarkable accessor methods that follow standard accessor
// conventions.

@synthesize animatesLayout = animatesLayout_;

@synthesize connectingLineColor = connectingLineColor_;

- (void) setConnectingLineColor:(UIColor *)newConnectingLineColor
{
    if (connectingLineColor_ != newConnectingLineColor) {
        [connectingLineColor_ release];
        connectingLineColor_ = [newConnectingLineColor retain];
        [[self rootSubtreeView] recursiveSetConnectorsViewsNeedDisplay];
    }
}

@synthesize contentMargin = contentMargin_;

- (void) setContentMargin:(CGFloat)newContentMargin
{
    if (contentMargin_ != newContentMargin) {
        contentMargin_ = newContentMargin;
        [self setNeedsGraphLayout];
    }
}

@synthesize parentChildSpacing = parentChildSpacing_;

- (void) setParentChildSpacing:(CGFloat)newParentChildSpacing
{
    if (parentChildSpacing_ != newParentChildSpacing) {
        parentChildSpacing_ = newParentChildSpacing;
        [self setNeedsGraphLayout];
    }
}

@synthesize siblingSpacing = siblingSpacing_;

- (void) setSiblingSpacing:(CGFloat)newSiblingSpacing
{
    if (siblingSpacing_ != newSiblingSpacing) {
        siblingSpacing_ = newSiblingSpacing;
        [self setNeedsGraphLayout];
    }
}

@synthesize treeGraphOrientation = treeGraphOrientation_;

- (void) setTreeGraphOrientation:(PSTreeGraphOrientationStyle)newTreeGraphOrientation
{
    if (treeGraphOrientation_ != newTreeGraphOrientation) {
        treeGraphOrientation_ = newTreeGraphOrientation;
        [[self rootSubtreeView] recursiveSetConnectorsViewsNeedDisplay];
    }
}

@synthesize treeGraphFlipped = treeGraphFlipped_;

- (void) setTreeGraphFlipped:(BOOL)newTreeGraphFlipped
{
    if (treeGraphFlipped_ != newTreeGraphFlipped) {
        treeGraphFlipped_ = newTreeGraphFlipped;
        [[self rootSubtreeView] recursiveSetConnectorsViewsNeedDisplay];
    }
}

@synthesize connectingLineStyle = connectingLineStyle_;

- (void) setConnectingLineStyle:(PSTreeGraphConnectingLineStyle)newConnectingLineStyle
{
    if (connectingLineStyle_ != newConnectingLineStyle) {
        connectingLineStyle_ = newConnectingLineStyle;
        [[self rootSubtreeView] recursiveSetConnectorsViewsNeedDisplay];
    }
}

@synthesize connectingLineWidth = connectingLineWidth_;

- (void) setConnectingLineWidth:(CGFloat)newConnectingLineWidth {
    if (connectingLineWidth_ != newConnectingLineWidth) {
        connectingLineWidth_ = newConnectingLineWidth;
        [[self rootSubtreeView] recursiveSetConnectorsViewsNeedDisplay];
    }
}

@synthesize resizesToFillEnclosingScrollView = resizesToFillEnclosingScrollView_;

- (void) setResizesToFillEnclosingScrollView:(BOOL)flag
{
    if (resizesToFillEnclosingScrollView_ != flag) {
        resizesToFillEnclosingScrollView_ = flag;
        [self updateFrameSizeForContentAndClipView];
        [self updateRootSubtreeViewPositionForSize:[[self rootSubtreeView] frame].size];
    }
}

@synthesize showsSubtreeFrames = showsSubtreeFrames_; // DEBUG

- (void) setShowsSubtreeFrames:(BOOL)newShowsSubtreeFrames
{
    if (showsSubtreeFrames_ != newShowsSubtreeFrames) {
        showsSubtreeFrames_ = newShowsSubtreeFrames;
        [[self rootSubtreeView] resursiveSetSubtreeBordersNeedDisplay];
    }
}


#pragma mark - Initialization

- (void) configureDefaults
{
	[self setBackgroundColor: [UIColor colorWithRed:0.55 green:0.76 blue:0.93 alpha:1.0]];
	//[self setClipsToBounds:YES];

	// Initialize ivars directly.  As a rule, it's best to avoid invoking accessors from an -init... method,
	// since they may wrongly expect the instance to be fully formed.

	// May be configured by user in code, loaded from NSCoder, etc
	connectingLineColor_ = [[UIColor blackColor] retain];
	contentMargin_ = 20.0;
	parentChildSpacing_ = 50.0;
	siblingSpacing_ = 10.0;
	animatesLayout_ = YES;
	resizesToFillEnclosingScrollView_ = YES;
	treeGraphFlipped_ = NO;
	treeGraphOrientation_ = PSTreeGraphOrientationStyleHorizontal ;
	connectingLineStyle_ = PSTreeGraphConnectingLineStyleOrthogonal ;
	connectingLineWidth_ = 1.0;

    // Internal
    layoutAnimationSuppressed_ = NO;
	showsSubtreeFrames_ = NO;
	minimumFrameSize_ = CGSizeMake(2.0 * contentMargin_, 2.0 * contentMargin_);
	selectedModelNodes_ = [[NSMutableSet alloc] init];
    modelNodeToSubtreeViewMapTable_ = [[NSMutableDictionary dictionaryWithCapacity:10] retain];

    // If this has been configured by the XIB, leave it during initialization.
    if (inputView_ == nil) {
        inputView_ = [[UIView alloc] initWithFrame:CGRectZero];
    }
}


#pragma mark - Resource Management

- (void) dealloc
{
	// iOS 4.0 and above ONLY
	[cachedNodeViewNib_ release];

    self.delegate = nil;

    [inputView_ release];
    [nodeViewNibName_ release];
    [selectedModelNodes_ release];
    [modelRoot_ release];
    [modelNodeToSubtreeViewMapTable_ release];
    // [backgroundColor release];
    [super dealloc];
}


#pragma mark - UIView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureDefaults];
    }
    return self;
}


#pragma mark - NSCoding

- (void) encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeBool:animatesLayout_ forKey:@"animatesLayout"];
    [encoder encodeFloat:contentMargin_ forKey:@"contentMargin"];
    [encoder encodeFloat:parentChildSpacing_ forKey:@"parentChildSpacing"];
    [encoder encodeFloat:siblingSpacing_ forKey:@"siblingSpacing"];
    [encoder encodeBool:resizesToFillEnclosingScrollView_ forKey:@"resizesToFillEnclosingScrollView"];
    [encoder encodeObject:connectingLineColor_ forKey:@"connectingLineColor"];
    [encoder encodeFloat:connectingLineWidth_ forKey:@"connectingLineWidth"];

    [encoder encodeInt:treeGraphOrientation_ forKey:@"treeGraphOrientation"];
    [encoder encodeInt:connectingLineStyle_ forKey:@"connectingLineStyle"];
}

- (id) initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {

        [self configureDefaults];

        if ([decoder containsValueForKey:@"animatesLayout"])
            animatesLayout_ = [decoder decodeBoolForKey:@"animatesLayout"];
        if ([decoder containsValueForKey:@"contentMargin"])
            contentMargin_ = [decoder decodeFloatForKey:@"contentMargin"];
        if ([decoder containsValueForKey:@"parentChildSpacing"])
            parentChildSpacing_ = [decoder decodeFloatForKey:@"parentChildSpacing"];
        if ([decoder containsValueForKey:@"siblingSpacing"])
            siblingSpacing_ = [decoder decodeFloatForKey:@"siblingSpacing"];
        if ([decoder containsValueForKey:@"resizesToFillEnclosingScrollView"])
            resizesToFillEnclosingScrollView_ = [decoder decodeBoolForKey:@"resizesToFillEnclosingScrollView"];
        if ([decoder containsValueForKey:@"connectingLineColor"])
            connectingLineColor_ = [[decoder decodeObjectForKey:@"connectingLineColor"] retain];
        if ([decoder containsValueForKey:@"connectingLineWidth"])
            connectingLineWidth_ = [decoder decodeFloatForKey:@"connectingLineWidth"];

        if ([decoder containsValueForKey:@"treeGraphOrientation"])
            treeGraphOrientation_ = [decoder decodeIntForKey:@"treeGraphOrientation"];
        if ([decoder containsValueForKey:@"connectingLineStyle"])
            connectingLineStyle_ = [decoder decodeIntForKey:@"connectingLineStyle"];
    }
    return self;
}


#pragma mark - Root SubtreeView Access

- (PSBaseSubtreeView *) rootSubtreeView
{
    return [self subtreeViewForModelNode:[self modelRoot]];
}


#pragma mark - Node View Nib Caching

// iOS 4.0 and above ONLY -

- (UINib *) cachedNodeViewNib {
    return cachedNodeViewNib_;

    // If 3.x Support required, change references to UINib to ID (careful not to modify
    // the one below.) uncomment the following code, test. Note: Does not check for valid
    // [self nodeViewNibName].

    //    if (!_cachedNodeViewNib) {
    //        Class cls = NSClassFromString(@"UINib");
    //        if ([cls respondsToSelector:@selector(nibWithNibName:bundle:)]) {
    //            _cachedNodeViewNib = [[cls nibWithNibName:[self nodeViewNibName] bundle:[NSBundle mainBundle]] retain];
    //        }
    //    }
}

- (void) setCachedNodeViewNib:(UINib *)newNib {
    if (cachedNodeViewNib_ != newNib) {
        [cachedNodeViewNib_ release];
        cachedNodeViewNib_ = [newNib retain];
    }
}


#pragma mark - Node View Nib Specification

@synthesize nodeViewNibName = nodeViewNibName_;

- (void) setNodeViewNibName:(NSString *)newName
{
    if (nodeViewNibName_ != newName) {

		// iOS 4.0 and above ONLY
		[self setCachedNodeViewNib:nil];

        [nodeViewNibName_ release];
        nodeViewNibName_ = [newName copy];

        // TODO: Tear down and (later) rebuild view tree.
    }
}


#pragma mark - Selection State

// The unordered set of model nodes that are currently selected in the TreeGraph.  When
// no nodes are selected, this is an empty NSSet.  It will never be nil (and attempting
// to set it to nil is not allowed.).

@synthesize selectedModelNodes = selectedModelNodes_;

- (void) setSelectedModelNodes:(NSSet *)newSelectedModelNodes
{
    NSParameterAssert(newSelectedModelNodes != nil); // Never pass nil. Pass [NSSet set] instead.

    // Verify that each of the nodes in the new selection is in the TreeGraph's assigned model tree.
    for (id modelNode in newSelectedModelNodes) {
        NSAssert([self modelNodeIsInAssignedTree:modelNode], @"modelNode is not in the tree");
    }

    if (selectedModelNodes_ != newSelectedModelNodes) {

		// Determine which nodes are changing selection state (either becoming selected, or ceasing to
        // be selected), and mark affected areas as needing display.  Take the union of the previous and
        // new selected node sets, subtract the set of nodes that are in both the old and new selection,
        // and the result is the set of nodes whose selection state is changing.

        NSMutableSet *combinedSet = [selectedModelNodes_ mutableCopy];
        [combinedSet unionSet:newSelectedModelNodes];

        NSMutableSet *intersectionSet = [selectedModelNodes_ mutableCopy];
        [intersectionSet intersectSet:newSelectedModelNodes];

        NSMutableSet *differenceSet = [combinedSet mutableCopy];
        [differenceSet minusSet:intersectionSet];

        // Discard the old selectedModelNodes set and replace it with the new one.
        [selectedModelNodes_ release];
        selectedModelNodes_ = [newSelectedModelNodes mutableCopy];

        for (id <PSTreeGraphModelNode> modelNode in differenceSet) {
            PSBaseSubtreeView *subtreeView = [self subtreeViewForModelNode:modelNode];
            UIView *nodeView = [subtreeView nodeView];
            if (nodeView && [nodeView isKindOfClass:[PSBaseLeafView class]]) {
                // TODO: Selection-highlighting is currently hardwired to our use of ContainerView.
                // This should be generalized.
                [(PSBaseLeafView *)nodeView setShowingSelected:([newSelectedModelNodes containsObject:modelNode] ? YES : NO)];
            }
        }

        // Release the temporary sets we created.
        [differenceSet release];
        [combinedSet release];
        [intersectionSet release];
    }
}

- (id <PSTreeGraphModelNode> ) singleSelectedModelNode
{
    NSSet *selection = [self selectedModelNodes];
    return ([selection count] == 1) ? [selection anyObject] : nil;
}

- (CGRect) selectionBounds
{
    return [self boundsOfModelNodes:[self selectedModelNodes]];
}


#pragma mark - Graph Building

- (PSBaseSubtreeView *) newGraphForModelNode:(id <PSTreeGraphModelNode> )modelNode
{
    NSParameterAssert(modelNode);

    PSBaseSubtreeView *subtreeView = [[PSBaseSubtreeView alloc] initWithModelNode:modelNode];
    if (subtreeView) {

        // Get nib from which to load nodeView.
        UINib *nodeViewNib = [self cachedNodeViewNib];

        if (nodeViewNib == nil) {
            NSString *nibName = [self nodeViewNibName];
            NSAssert(nibName != nil,
                     @"You must set a non-nil nodeViewNibName for TreeGraph to be able to build its view tree");
            if (nibName != nil) {
                nodeViewNib = [UINib nibWithNibName:[self nodeViewNibName] bundle:[NSBundle mainBundle]];
                [self setCachedNodeViewNib:nodeViewNib];
            }
        }

        NSArray *nibViews = nil;
        if (nodeViewNib != nil) {
            // Instantiate the nib to create our nodeView and associate it with the subtreeView (the nib's owner).
            nibViews = [nodeViewNib instantiateWithOwner:subtreeView options:nil];
        }

		if ( nibViews ) {

			// Ask our delete to configure the interface for the modelNode displayed in nodeView.
			if ( [[self delegate] conformsToProtocol:@protocol(PSTreeGraphDelegate)] ) {
				[[self delegate] configureNodeView:[subtreeView nodeView] withModelNode:modelNode ];
			}

            // Add the nodeView as a subview of the subtreeView.
            [subtreeView addSubview:[subtreeView nodeView]];

            // Register the subtreeView in our map table, so we can look it up by its modelNode.
            [self setSubtreeView:subtreeView forModelNode:modelNode];

            // Recurse to create a SubtreeView for each descendant of modelNode.
            NSArray *childModelNodes = [modelNode childModelNodes];

            NSAssert(childModelNodes != nil,
                     @"childModelNodes should return an empty array ([NSArray array]), not nil.");

            if (childModelNodes != nil) {
                for (id <PSTreeGraphModelNode> childModelNode in childModelNodes) {
                    PSBaseSubtreeView *childSubtreeView = [self newGraphForModelNode:childModelNode];
                    if (childSubtreeView != nil) {

                        // Add the child subtreeView behind the parent subtreeView's nodeView (so that when we
                        // collapse the subtree, its nodeView will remain frontmost).

                        [subtreeView insertSubview:childSubtreeView belowSubview:[subtreeView nodeView]];
                        [childSubtreeView release];
                    }
                }
            }

        } else {
            [subtreeView release];
            subtreeView = nil;
        }
    }

    return subtreeView;
}

- (void) buildGraph
{
    @autoreleasepool {

        // Traverse the model tree, building a SubtreeView for each model node.
        id <PSTreeGraphModelNode> root = [self modelRoot];
        if (root) {
            PSBaseSubtreeView *rootSubtreeView = [self newGraphForModelNode:root];
            if (rootSubtreeView) {
                [self addSubview:rootSubtreeView];
                [rootSubtreeView release];
            }
        }

    } // Drain the pool
}


#pragma mark - Layout

- (void) updateFrameSizeForContentAndClipView
{
    CGSize newFrameSize;
    CGSize newMinimumFrameSize = [self minimumFrameSize];

	// TODO: Additional checks to ensure we are in a UIScrollView
	UIScrollView *enclosingScrollView = (UIScrollView *)[self superview];


	if ( [self resizesToFillEnclosingScrollView] && enclosingScrollView ) {

        // This TreeGraph is a child of a UIScrollView: Size it to always fill the content area (at minimum).

		CGRect contentViewBounds = [enclosingScrollView bounds];
		newFrameSize.width = MAX(newMinimumFrameSize.width, contentViewBounds.size.width);
        newFrameSize.height = MAX(newMinimumFrameSize.height, contentViewBounds.size.height);

		[enclosingScrollView setContentSize:newFrameSize];

    } else {
        newFrameSize = newMinimumFrameSize;
    }

	self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            newFrameSize.width,
                            newFrameSize.height );

}

- (void) updateRootSubtreeViewPositionForSize:(CGSize)rootSubtreeViewSize
{
    // Position the rootSubtreeView within the TreeGraph.
    PSBaseSubtreeView *rootSubtreeView = [self rootSubtreeView];

    // BOOL animateLayout = [self animatesLayout] && ![self layoutAnimationSuppressed];
    CGPoint newOrigin;
    if ( [self resizesToFillEnclosingScrollView] ) {
        CGRect bounds = [self bounds];

		if (( [self treeGraphOrientation] == PSTreeGraphOrientationStyleHorizontal ) ||
            ( [self treeGraphOrientation] == PSTreeGraphOrientationStyleHorizontalFlipped )){
			newOrigin = CGPointMake([self contentMargin],
                                    0.5 * (bounds.size.height - rootSubtreeViewSize.height));
		} else {
			newOrigin = CGPointMake(0.5 * (bounds.size.width - rootSubtreeViewSize.width),
                                    [self contentMargin]);
		}

    } else {
        newOrigin = CGPointMake([self contentMargin],
                                [self contentMargin]);
    }

    // [(animateLayout ? [rootSubtreeView animator] : rootSubtreeView) setFrameOrigin:newOrigin];

	rootSubtreeView.frame = CGRectMake(newOrigin.x,
									   newOrigin.y,
									   rootSubtreeView.frame.size.width,
									   rootSubtreeView.frame.size.height );

}

- (void) parentClipViewDidResize:(id)object
{
	UIScrollView *enclosingScrollView = (UIScrollView *)[self superview];

	if ( enclosingScrollView && [enclosingScrollView isKindOfClass:[UIScrollView class]] ) {
        [self updateFrameSizeForContentAndClipView];
        [self updateRootSubtreeViewPositionForSize:[[self rootSubtreeView] frame].size];
        [self scrollSelectedModelNodesToVisibleAnimated:NO];
    }
}

- (void) layoutSubviews
{
    // Do graph layout if we need to.
    [self layoutGraphIfNeeded];
}

- (CGSize) layoutGraphIfNeeded
{
    PSBaseSubtreeView *rootSubtreeView = [self rootSubtreeView];
    if ([self needsGraphLayout] && [self modelRoot]) {

        // Do recursive graph layout, starting at our rootSubtreeView.
        CGSize rootSubtreeViewSize = [rootSubtreeView layoutGraphIfNeeded];

        // Compute self's new minimumFrameSize.  Make sure it's pixel-integral.
        CGFloat margin = [self contentMargin];
        CGSize minimumBoundsSize = CGSizeMake(rootSubtreeViewSize.width + 2.0 * margin,
                                              rootSubtreeViewSize.height + 2.0 * margin);

		[self setMinimumFrameSize:minimumBoundsSize];

        // Set the TreeGraph's frame size.
        [self updateFrameSizeForContentAndClipView];

        // Position the TreeGraph's root SubtreeView.
        [self updateRootSubtreeViewPositionForSize:rootSubtreeViewSize];
        
		if (( [self treeGraphOrientation] == PSTreeGraphOrientationStyleHorizontalFlipped ) ||
            ( [self treeGraphOrientation] == PSTreeGraphOrientationStyleVerticalFlipped )){
            [rootSubtreeView flipTreeGraph];
        }
        return rootSubtreeViewSize;
    } else {
        return rootSubtreeView ? [rootSubtreeView frame].size : CGSizeZero;
    }
}

- (BOOL) needsGraphLayout
{
    return [[self rootSubtreeView] needsGraphLayout];
}

- (void) setNeedsGraphLayout
{
    [[self rootSubtreeView] recursiveSetNeedsGraphLayout];
}

- (void) collapseRoot
{
    [[self rootSubtreeView] setExpanded:NO];
}

- (void) expandRoot
{
    [[self rootSubtreeView] setExpanded:YES];
}

- (IBAction) toggleExpansionOfSelectedModelNodes:(id)sender
{
    for (id <PSTreeGraphModelNode> modelNode in [self selectedModelNodes]) {
        PSBaseSubtreeView *subtreeView = [self subtreeViewForModelNode:modelNode];
        [subtreeView toggleExpansion:sender];
    }
}


#pragma mark - Scrolling

- (CGRect) boundsOfModelNodes:(NSSet *)modelNodes
{
    CGRect boundingBox = CGRectZero;
    BOOL   firstNodeFound = NO;
    for (id <PSTreeGraphModelNode> modelNode in modelNodes) {
        PSBaseSubtreeView *subtreeView = [self subtreeViewForModelNode:modelNode];
        if ( subtreeView && (subtreeView.hidden == NO) ) {
            UIView *nodeView = [subtreeView nodeView];
            if (nodeView) {
                CGRect rect = [self convertRect:[nodeView bounds] fromView:nodeView];

                if (!firstNodeFound) {
                    // The first node found gives us the starting boundingBox, after
                    // that we take the take union of each successive node.
                    boundingBox = rect;
                    firstNodeFound = YES;
                } else {
                    boundingBox = CGRectUnion(boundingBox, rect);
                }
            }
        }
    }

    return boundingBox;
}

- (void) scrollModelNodesToVisible:(NSSet *)modelNodes animated:(BOOL)animated
{
    CGRect targetRect = [self boundsOfModelNodes:modelNodes];
    if (!CGRectIsEmpty(targetRect)) {
        CGFloat padding = [self contentMargin];

		UIScrollView *parentScroll = (UIScrollView *)[self superview];

		if ( parentScroll && [parentScroll isKindOfClass:[UIScrollView class]] ) {
            targetRect = CGRectInset(targetRect, -padding, -padding);
//            NSLog(@"Scrolling to target rect: %@", NSStringFromCGRect(targetRect) );
			[parentScroll scrollRectToVisible:targetRect animated:animated];
		}
    }
}

- (void) scrollSelectedModelNodesToVisibleAnimated:(BOOL)animated
{
    [self scrollModelNodesToVisible:[self selectedModelNodes] animated:animated];
}


#pragma mark - Data Source

@synthesize modelRoot = modelRoot_;

- (void) setModelRoot:(id <PSTreeGraphModelNode> )newModelRoot
{
    NSParameterAssert(newModelRoot == nil || [newModelRoot conformsToProtocol:@protocol(PSTreeGraphModelNode)]);

    if ( modelRoot_ != newModelRoot ) {
        PSBaseSubtreeView *rootSubtreeView = [self rootSubtreeView];
        [rootSubtreeView removeFromSuperview];
        [modelNodeToSubtreeViewMapTable_ removeAllObjects];

        // Discard any previous selection.
        [self setSelectedModelNodes:[NSSet set]];

        // Switch to new modelRoot.
        modelRoot_ = newModelRoot;

        // Discard and reload content.
        [self buildGraph];
        [self setNeedsDisplay];
        [[self rootSubtreeView] resursiveSetSubtreeBordersNeedDisplay];
        [self layoutGraphIfNeeded];

        // Start with modelRoot selected.
        if ( modelRoot_ ) {
            [self setSelectedModelNodes:[NSSet setWithObject:modelRoot_]];
            [self scrollSelectedModelNodesToVisibleAnimated:NO];
        }
    }
}


#pragma mark - Node Hit-Testing

// Returns the model node under the given point, which must be expressed in the
// TreeGraph's interior (bounds) coordinate space.  If there is a collapsed subtree at the
// given point, returns the model node at the root of the collapsed subtree.  If there is
// no model node at the given point, returns nil.

- (id <PSTreeGraphModelNode> ) modelNodeAtPoint:(CGPoint)p
{
    // Since we've composed our content using views (SubtreeViews and enclosed nodeViews),
    // we can use UIView's -hitTest: method to easily identify our deepest descendant view
    // under the given point. We rely on the front-to-back order of hit-testing to ensure
    // that we return the root of a collapsed subtree, instead of one of its descendant nodes.
    // (To do this, we must make sure, when collapsing a subtree, to keep the SubtreeView's
    // nodeView frontmost among its siblings.)

    PSBaseSubtreeView *rootSubtreeView = [self rootSubtreeView];
    CGPoint subviewPoint = [self convertPoint:p toView:rootSubtreeView];
    id <PSTreeGraphModelNode> hitModelNode = [[self rootSubtreeView] modelNodeAtPoint:subviewPoint];

    return hitModelNode;
}


#pragma mark - Input and Navigation

@synthesize inputView = inputView_;

- (BOOL) canBecomeFirstResponder
{
    // Make TreeGraphs able to -canBecomeFirstResponder, so they can receive key events.
    return YES;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint viewPoint = [touch locationInView:self];

    // Identify the mdoel node (if any) that the user clicked, and make it the new selection.
    id <PSTreeGraphModelNode>  hitModelNode = [self modelNodeAtPoint:viewPoint];
    [self setSelectedModelNodes:(hitModelNode ? [NSSet setWithObject:hitModelNode] : [NSSet set])];

    // Respond to touch and become first responder.
    [self becomeFirstResponder];
}


- (void) moveToSiblingByRelativeIndex:(NSInteger)relativeIndex
{
    id <PSTreeGraphModelNode> modelNode = [self singleSelectedModelNode];
    if (modelNode) {
        id <PSTreeGraphModelNode> sibling = [self siblingOfModelNode:modelNode atRelativeIndex:relativeIndex];
        if (sibling) {
            [self setSelectedModelNodes:[NSSet setWithObject:sibling]];
        }
    } else if ([[self selectedModelNodes] count] == 0) {
        // If nothing selected, select root.
        [self setSelectedModelNodes:([self modelRoot] ? [NSSet setWithObject:[self modelRoot]] : nil)];
    }

    // Scroll new selection to visible.
    [self scrollSelectedModelNodesToVisibleAnimated:YES];
}

- (IBAction) moveToParent:(id)sender
{
    id <PSTreeGraphModelNode> modelNode = [self singleSelectedModelNode];
    if (modelNode) {
        if (modelNode != [self modelRoot]) {
            id <PSTreeGraphModelNode> parent = [modelNode parentModelNode];
            if (parent) {
                [self setSelectedModelNodes:[NSSet setWithObject:parent]];
            }
        }
    } else if ([[self selectedModelNodes] count] == 0) {
        // If nothing selected, select root.
        [self setSelectedModelNodes:([self modelRoot] ? [NSSet setWithObject:[self modelRoot]] : nil)];
    }

    // Scroll new selection to visible.
    [self scrollSelectedModelNodesToVisibleAnimated:YES];
}

- (IBAction) moveToNearestChild:(id)sender
{
    id <PSTreeGraphModelNode> modelNode = [self singleSelectedModelNode];
    if (modelNode) {
        PSBaseSubtreeView *subtreeView = [self subtreeViewForModelNode:modelNode];
        if (subtreeView && [subtreeView isExpanded]) {
            UIView *nodeView = [subtreeView nodeView];
            if (nodeView) {
                CGRect nodeViewFrame = [nodeView frame];
                id <PSTreeGraphModelNode> nearestChild = nil;
                if (( self.treeGraphOrientation == PSTreeGraphOrientationStyleHorizontal ) ||
                    ( self.treeGraphOrientation == PSTreeGraphOrientationStyleHorizontalFlipped )){
                    nearestChild = [subtreeView modelNodeClosestToY:CGRectGetMidY(nodeViewFrame)];
                } else {
                    nearestChild = [subtreeView modelNodeClosestToX:CGRectGetMidX(nodeViewFrame)];
                }
                if (nearestChild != nil) {
                    [self setSelectedModelNodes:[NSSet setWithObject:nearestChild]];
                }
            }
        }
    } else if ([[self selectedModelNodes] count] == 0) {
        // If nothing selected, select root.
        [self setSelectedModelNodes:([self modelRoot] ? [NSSet setWithObject:[self modelRoot]] : nil)];
    }

    // Scroll new selection to visible.
    [self scrollSelectedModelNodesToVisibleAnimated:YES];
}

- (void) moveUp:(id)sender
{
    if (( self.treeGraphOrientation == PSTreeGraphOrientationStyleHorizontal ) ||
        ( self.treeGraphOrientation == PSTreeGraphOrientationStyleHorizontalFlipped )){
        [self moveToSiblingByRelativeIndex:1];
    } else {
        [self moveToParent:sender];
    }

}

- (void) moveDown:(id)sender
{
    if (( self.treeGraphOrientation == PSTreeGraphOrientationStyleHorizontal ) ||
        ( self.treeGraphOrientation == PSTreeGraphOrientationStyleHorizontalFlipped )){
        [self moveToSiblingByRelativeIndex:-1];
    } else {
        [self moveToNearestChild:sender];
    }

}

- (void) moveLeft:(id)sender
{
    if (( self.treeGraphOrientation == PSTreeGraphOrientationStyleHorizontal ) ||
        ( self.treeGraphOrientation == PSTreeGraphOrientationStyleHorizontalFlipped )){
        [self moveToParent:sender];
    } else {
        [self moveToSiblingByRelativeIndex:1];
    }

}

- (void) moveRight:(id)sender
{
    if (( self.treeGraphOrientation == PSTreeGraphOrientationStyleHorizontal ) ||
        ( self.treeGraphOrientation == PSTreeGraphOrientationStyleHorizontalFlipped )){
        [self moveToNearestChild:sender];
    } else {
        [self moveToSiblingByRelativeIndex:-1];
    }

}


#pragma mark UIKeyInput Protocol Methods

- (BOOL) hasText
{
    if ( [self modelRoot] != nil ) {
        return YES;
    }
    return NO;
}

- (void) insertText:(NSString *)theText
{
    // Hardware keyboard, desktop keyboard in simulator support.
    if (theText && [theText length] > 0) {
        switch ([theText characterAtIndex:0]) {
            case ' ':
                [self toggleExpansionOfSelectedModelNodes:self];
                break;
            case 'w':
                if (self.treeGraphOrientation == PSTreeGraphOrientationStyleVerticalFlipped ) {
                    [self moveDown:self];
                } else {
                    [self moveUp:self];
                }
                break;
            case 'a':
                if (self.treeGraphOrientation == PSTreeGraphOrientationStyleHorizontalFlipped ) {
                    [self moveRight:self];
                } else {
                    [self moveLeft:self];
                }
                break;
            case 's':
                if (self.treeGraphOrientation == PSTreeGraphOrientationStyleVerticalFlipped ) {
                    [self moveUp:self];
                } else {
                    [self moveDown:self];
                }
                break;
            case 'd':
                if (self.treeGraphOrientation == PSTreeGraphOrientationStyleHorizontalFlipped ) {
                    [self moveLeft:self];
                } else {
                    [self moveRight:self];
                }
                break;

            default:
                // Input from keyboard or other device not handled.
                break;
        }
    }
}

- (void) deleteBackward
{
    [self moveLeft:nil];
}


#pragma mark - Gesture Event Handling

//- (void) beginGestureWithEvent:(NSEvent *)event {
//    // Temporarily suspend layout animations during handling of a gesture sequence.
//    [self setLayoutAnimationSuppressed:YES];
//}
//
//- (void) endGestureWithEvent:(NSEvent *)event {
//    // Re-enable layout animations at the end of a gesture sequence.
//    [self setLayoutAnimationSuppressed:NO];
//}
//
//- (void) magnifyWithEvent:(NSEvent *)event {
//    CGFloat spacing = [self parentChildSpacing];
//    spacing = spacing * (1.0 + [event magnification]);
//    [self setParentChildSpacing:spacing];
//}
//
//- (void) swipeWithEvent:(NSEvent *)event {
//    // Expand or collapse the entire tree according to the direction of the swipe.
//    // (An alternative behavior might be to identify node under mouse, and
//    // collapse/expand that instead of root node.)
//
//    CGFloat deltaX = [event deltaX];
//    if (deltaX < 0.0) {
//        // Swipe was to the right.
//        [self expandRoot];
//    } else if (deltaX > 0.0) {
//        // Swipe was to the left.
//        [self collapseRoot];
//    }
//}


@end


#pragma mark -
@implementation PSBaseTreeGraphView (Internal)


#pragma mark - ModelNode -> SubtreeView Relationship Management

- (PSBaseSubtreeView *) subtreeViewForModelNode:(id)modelNode
{
    return [modelNodeToSubtreeViewMapTable_ objectForKey:modelNode];
}

- (void) setSubtreeView:(PSBaseSubtreeView *)subtreeView forModelNode:(id)modelNode
{
    [modelNodeToSubtreeViewMapTable_ setObject:subtreeView forKey:modelNode];
}


#pragma mark - Model Tree Navigation

- (BOOL) modelNode:(id <PSTreeGraphModelNode> )modelNode
    isDescendantOf:(id <PSTreeGraphModelNode> )possibleAncestor
{
    NSParameterAssert(modelNode != nil);
    NSParameterAssert(possibleAncestor != nil);

    id <PSTreeGraphModelNode> node = [modelNode parentModelNode];
    while (node != nil) {
        if (node == possibleAncestor) {
            return YES;
        }
        node = [node parentModelNode];
    }
    return NO;
}

- (BOOL) modelNodeIsInAssignedTree:(id <PSTreeGraphModelNode> )modelNode
{
    NSParameterAssert(modelNode != nil);

    id <PSTreeGraphModelNode> root = [self modelRoot];
    return (modelNode == root || [self modelNode:modelNode isDescendantOf:root]) ? YES : NO;
}

- (id <PSTreeGraphModelNode> ) siblingOfModelNode:(id <PSTreeGraphModelNode> )modelNode
                                  atRelativeIndex:(NSInteger)relativeIndex
{
    NSParameterAssert(modelNode != nil);
    NSAssert([self modelNodeIsInAssignedTree:modelNode], @"modelNode is not in the tree");

    if (modelNode == [self modelRoot]) {
        // modelNode is modelRoot.  Disallow traversal to its siblings (if it has any).
        return nil;
    } else {
        // modelNode is a descendant of modelRoot.
        // Find modelNode's position in its parent node's array of children.
        id <PSTreeGraphModelNode> parent = [modelNode parentModelNode];
        NSArray *siblings = [parent childModelNodes];

        NSAssert(siblings != nil,
                 @"childModelNodes should return an empty array ([NSArray array]), not nil.");

        if (siblings != nil) {
            NSInteger index = [siblings indexOfObject:modelNode];
            if (index != NSNotFound) {
                index += relativeIndex;
                if (index >= 0 && index < [siblings count]) {
                    return [siblings objectAtIndex:index];
                }
            }
        }
        return nil;
    }
}


@end