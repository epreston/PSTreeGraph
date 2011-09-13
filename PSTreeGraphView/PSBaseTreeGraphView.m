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

#import "PSTreeGraphModelNode.h"

// For displayIfNeeded
#import <QuartzCore/QuartzCore.h>


@implementation PSBaseTreeGraphView

@synthesize delegate = _delegate;
@synthesize animatesLayout = _animatesLayout;
@synthesize layoutAnimationSuppressed = _layoutAnimationSuppressed;
@synthesize minimumFrameSize = _minimumFrameSize;


#pragma mark - Creating Instances

- (void) configureDetaults 
{
	[self setBackgroundColor: [UIColor colorWithRed:0.55f green:0.76f blue:0.93f alpha:1.0f]];
	//[self setClipsToBounds:YES];
	
	// Initialize ivars directly.  As a rule, it's best to avoid invoking accessors from an -init... method,
	// since they may wrongly expect the instance to be fully formed.
	
	_modelNodeToSubtreeViewMapTable = [[NSMutableDictionary dictionaryWithCapacity:10] retain];
	_connectingLineColor = [[UIColor blackColor] retain];
	_contentMargin = 20.0f;
	_parentChildSpacing = 50.0f;
	_siblingSpacing = 10.0f;
	_animatesLayout = YES;
	_resizesToFillEnclosingScrollView = YES;
	_treeGraphOrientation = PSTreeGraphOrientationStyleHorizontal ;
	_layoutAnimationSuppressed = NO;
	_connectingLineStyle = PSTreeGraphConnectingLineStyleOrthogonal ;
	_connectingLineWidth = 1.0f;
	_showsSubtreeFrames = NO;
	_minimumFrameSize = CGSizeMake(2.0f * _contentMargin, 2.0f * _contentMargin);
	_selectedModelNodes = [[NSMutableSet alloc] init];
	
	// [self setLayerContentsRedrawPolicy:UIViewLayerContentsRedrawNever];
}

- (id) initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
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
	// iOS 4.0 and above ONLY
	// [cachedNodeViewNib release];
    
    self.delegate = nil;
	
    [_nodeViewNibBundle release];
    [_nodeViewNibName release];
    [_selectedModelNodes release];
    [_modelRoot release];
    [_modelNodeToSubtreeViewMapTable release];
    // [backgroundColor release];
    [super dealloc];
}

#pragma mark - Root SubtreeView Access

- (PSBaseSubtreeView *) rootSubtreeView 
{
    return [self subtreeViewForModelNode:[self modelRoot]];
}


#pragma mark - Node View Nib Specification 

@synthesize nodeViewNibName = _nodeViewNibName;

- (void)setNodeViewNibName:(NSString *)newName 
{
    if (_nodeViewNibName != newName) {
        
		// iOS 4.0 and above ONLY
		// [self setCachedNodeViewNib:nil];
		
        [_nodeViewNibName release];
        _nodeViewNibName = [newName copy];
		
        // TODO: Tear down and (later) rebuild view tree.
    }
}

@synthesize nodeViewNibBundle = _nodeViewNibBundle;

- (void) setNodeViewNibBundle:(NSBundle *)newBundle 
{
    if (_nodeViewNibBundle != newBundle) {
        
		// iOS 4.0 and above ONLY
		// [self setCachedNodeViewNib:nil];
		
        [_nodeViewNibBundle release];
        _nodeViewNibBundle = [newBundle retain];
		
        // TODO: Tear down and (later) rebuild view tree.
    }
}


#pragma mark - Node View Nib Caching

// iOS 4.0 and above ONLY

//- (UINib *)cachedNodeViewNib {
//    return cachedNodeViewNib;
//}
//
//- (void)setCachedNodeViewNib:(UINib *)newNib {
//    if (cachedNodeViewNib != newNib) {
//        [cachedNodeViewNib release];
//        cachedNodeViewNib = [newNib retain];
//    }
//}


#pragma mark - Selection State

// The unordered set of model nodes that are currently selected in the TreeGraph.  When 
// no nodes are selected, this is an empty NSSet.  It will never be nil (and attempting
// to set it to nil will raise an exception).
 
@synthesize selectedModelNodes = _selectedModelNodes;

- (void) setSelectedModelNodes:(NSSet *)newSelectedModelNodes 
{
    NSParameterAssert(newSelectedModelNodes != nil); // Never pass nil. Pass [NSSet set] instead.
    
    // Verify that each of the nodes in the new selection is in the TreeGraph's assigned model tree.
    for (id modelNode in newSelectedModelNodes) {
        NSAssert([self modelNodeIsInAssignedTree:modelNode], @"modelNode is not in the tree");
    }
	
    if (_selectedModelNodes != newSelectedModelNodes) {
        
		// Determine which nodes are changing selection state (either becoming selected, or ceasing to 
        // be selected), and mark affected areas as needing display.  Take the union of the previous and
        // new selected node sets, subtract the set of nodes that are in both the old and new selection,
        // and the result is the set of nodes whose selection state is changing.
		
        NSMutableSet *combinedSet = [_selectedModelNodes mutableCopy];
        [combinedSet unionSet:newSelectedModelNodes];
		
        NSMutableSet *intersectionSet = [_selectedModelNodes mutableCopy];
        [intersectionSet intersectSet:newSelectedModelNodes];
		
        NSMutableSet *differenceSet = [combinedSet mutableCopy];
        [differenceSet minusSet:intersectionSet];
		
        // Discard the old selectedModelNodes set and replace it with the new one.
        [_selectedModelNodes release];
        _selectedModelNodes = [newSelectedModelNodes mutableCopy];
		
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
        // NSNib *nodeViewNib = [self cachedNodeViewNib];
		
		//        if (nodeViewNib == nil) {
		//            NSString *nibName = [self nodeViewNibName];
		//            NSAssert(nibName != nil, @"You must set a non-nil nodeViewNibName for TreeGraph to be able to build its view tree");
		//            if (nibName != nil) {
		//                nodeViewNib = [[NSNib alloc] initWithNibNamed:[self nodeViewNibName] bundle:[self nodeViewNibBundle]];
		//                [self setCachedNodeViewNib:nodeViewNib];
		//            }
		//        }
		
		NSArray *nibViews = nil;
		NSString *nibName = [self nodeViewNibName];
        
		NSAssert(nibName != nil, @"You must set a non-nil nodeViewNibName for TreeGraph to be able to build its view tree");
        
		if (nibName != nil) {
			
			// nibViews = [[self nodeViewNibBundle] loadNibNamed:[self nodeViewNibName] owner:subtreeView options:nil];
			nibViews = [[NSBundle mainBundle] loadNibNamed:[self nodeViewNibName] owner:subtreeView options:nil];
		}
		
        // Instantiate the nib to create our nodeView and associate it with the subtreeView (the nib's owner).
        // TODO: Keep track of topLevelObjects, to release later.
        
		//if ([nodeViewNib instantiateNibWithOwner:subtreeView topLevelObjects:nil]) {
		
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
    // Traverse the model tree, building a SubtreeView for each model node.
    id <PSTreeGraphModelNode> root = [self modelRoot];
    if (root) {
        PSBaseSubtreeView *rootSubtreeView = [self newGraphForModelNode:root];
        if (rootSubtreeView) {
            [self addSubview:rootSubtreeView];
            [rootSubtreeView release];
        }
    }
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
	
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newFrameSize.width, newFrameSize.height );
	
}

- (void) updateRootSubtreeViewPositionForSize:(CGSize)rootSubtreeViewSize 
{	
    // Position the rootSubtreeView within the TreeGraph.
    PSBaseSubtreeView *rootSubtreeView = [self rootSubtreeView];
	
    // BOOL animateLayout = [self animatesLayout] && ![self layoutAnimationSuppressed];
    CGPoint newOrigin;
    if ( [self resizesToFillEnclosingScrollView] ) {
        CGRect bounds = [self bounds];
		
		if ( [self treeGraphOrientation] == PSTreeGraphOrientationStyleHorizontal ) {
			newOrigin = CGPointMake([self contentMargin], 0.5 * (bounds.size.height - rootSubtreeViewSize.height));
		} else {
			newOrigin = CGPointMake(0.5 * (bounds.size.width - rootSubtreeViewSize.width), [self contentMargin]);
		}

    } else {
        newOrigin = CGPointMake([self contentMargin], [self contentMargin]);
    }
	
    // [(animateLayout ? [rootSubtreeView animator] : rootSubtreeView) setFrameOrigin:newOrigin];
	rootSubtreeView.frame = CGRectMake(newOrigin.x, 
									   newOrigin.y, 
									   rootSubtreeView.frame.size.width, 
									   rootSubtreeView.frame.size.height );
	
}

@synthesize treeGraphOrientation = _treeGraphOrientation;

- (void) setTreeGraphOrientation:(PSTreeGraphOrientationStyle)newTreeGraphOrientation 
{
    if (_treeGraphOrientation != newTreeGraphOrientation) {
        _treeGraphOrientation = newTreeGraphOrientation;
        [[self rootSubtreeView] recursiveSetConnectorsViewsNeedDisplay];
    }
}

@synthesize resizesToFillEnclosingScrollView = _resizesToFillEnclosingScrollView;

- (void) setResizesToFillEnclosingScrollView:(BOOL)flag 
{
    if (_resizesToFillEnclosingScrollView != flag) {
        _resizesToFillEnclosingScrollView = flag;
        [self updateFrameSizeForContentAndClipView];
        [self updateRootSubtreeViewPositionForSize:[[self rootSubtreeView] frame].size];
    }
}

- (void) parentClipViewDidResize:(id)object 
{
	UIScrollView *enclosingScrollView = (UIScrollView *)[self superview];
	
	if ( enclosingScrollView && [enclosingScrollView isKindOfClass:[UIScrollView class]] ) {
        [self updateFrameSizeForContentAndClipView];
        [self updateRootSubtreeViewPositionForSize:[[self rootSubtreeView] frame].size];
    }
}

- (void) layoutSubviews 
{	
    // Do graph layout if we need to.
    [self layoutGraphIfNeeded];
	
    // Always call up to [super viewWillDraw], either before or after doing your work, to continue 
	// the -viewWillDraw recursion for descendant views.
	
    [super layoutSubviews];
}

- (CGSize) layoutGraphIfNeeded 
{
    PSBaseSubtreeView *rootSubtreeView = [self rootSubtreeView];
    if ([self needsGraphLayout] && [self modelRoot]) {
		
        // TODO: Build graph tree if needed.
		
        // Do recursive graph layout, starting at our rootSubtreeView.
        CGSize rootSubtreeViewSize = [rootSubtreeView layoutGraphIfNeeded];
		
        // Compute self's new minimumFrameSize.  Make sure it's pixel-integral.
        CGFloat margin = [self contentMargin];
        CGSize minimumBoundsSize = CGSizeMake(rootSubtreeViewSize.width + 2.0 * margin, rootSubtreeViewSize.height + 2.0 * margin);
		
		[self setMinimumFrameSize:minimumBoundsSize];
		
		
        // Set the TreeGraph's frame size.
        [self updateFrameSizeForContentAndClipView];
		
        // Position the TreeGraph's root SubtreeView.
        [self updateRootSubtreeViewPositionForSize:rootSubtreeViewSize];
		
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
    [self setNeedsDisplay];
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

- (CGRect) boundsOfModelNodes:(NSSet *)modelNodes 
{
    CGRect boundingBox = CGRectZero;
    for (id <PSTreeGraphModelNode> modelNode in modelNodes) {
        PSBaseSubtreeView *subtreeView = [self subtreeViewForModelNode:modelNode];
        if (subtreeView && [subtreeView isExpanded]) {
            UIView *nodeView = [subtreeView nodeView];
            if (nodeView) {
                CGRect rect = [self convertRect:[nodeView bounds] fromView:nodeView];
                boundingBox = CGRectUnion(boundingBox, rect);
            }
        }
    }
    return boundingBox;
}


#pragma mark - Scrolling

- (void) scrollModelNodesToVisible:(NSSet *)modelNodes 
{
    CGRect targetRect = [self boundsOfModelNodes:modelNodes];
    if (!CGRectIsEmpty(targetRect)) {
        CGFloat padding = [self contentMargin];
		
		UIScrollView *parentScroll = (UIScrollView *)[self superview];
		
		if ( parentScroll ) {
			[parentScroll scrollRectToVisible:CGRectInset(targetRect, -padding, -padding) animated:YES];
		}
        
    }
}

- (void) scrollSelectedModelNodesToVisible 
{
    [self scrollModelNodesToVisible:[self selectedModelNodes]];
}


#pragma mark - Data Source

@synthesize modelRoot = _modelRoot;

- (void) setModelRoot:(id <PSTreeGraphModelNode> )newModelRoot 
{    
    NSParameterAssert(newModelRoot == nil || [newModelRoot conformsToProtocol:@protocol(PSTreeGraphModelNode)]);
    
    if ( _modelRoot != newModelRoot ) {
        PSBaseSubtreeView *rootSubtreeView = [self rootSubtreeView];
        [rootSubtreeView removeFromSuperview];
        [_modelNodeToSubtreeViewMapTable removeAllObjects];
		
        // Discard any previous selection.
        [self setSelectedModelNodes:[NSSet set]];
		
        // Switch to new modelRoot.
        _modelRoot = newModelRoot;
		
        // Discard and reload content.
        [self buildGraph];
        [self setNeedsDisplay];
		
        // Start with modelRoot selected.
        if ( _modelRoot ) {
			[[self rootSubtreeView] resursiveSetSubtreeBordersNeedDisplay];
			
            [self setSelectedModelNodes:[NSSet setWithObject:_modelRoot]];
            [self scrollSelectedModelNodesToVisible];
        }
    }
}


#pragma mark - Node Hit-Testing

// Returns the model node under the given point, which must be expressed in the TreeGraph's interior (bounds)
// coordinate space.  If there is a collapsed subtree at the given point, returns the model node at the root
// of the collapsed subtree.  If there is no model node at the given point, returns nil.
 
- (id <PSTreeGraphModelNode> ) modelNodeAtPoint:(CGPoint)p 
{
    // Since we've composed our content using views (SubtreeViews and enclosed nodeViews), we can use 
    // UIView's -hitTest: method to easily identify our deepest descendant view under the given point.  
    // We rely on the front-to-back order of hit-testing to ensure that we return the root of a collapsed
    // subtree, instead of one of its descendant nodes.  (To do this, we must make sure, when collapsing a
    // subtree, to keep the SubtreeView's nodeView frontmost among its siblings.)
    
    PSBaseSubtreeView *rootSubtreeView = [self rootSubtreeView];
    CGPoint subviewPoint = [self convertPoint:p toView:rootSubtreeView];
    id <PSTreeGraphModelNode> hitModelNode = [[self rootSubtreeView] modelNodeAtPoint:subviewPoint];
	
    return hitModelNode;
}


#pragma mark - Key Event Handling

// Make TreeGraphs able to -becomeFirstResponder, so they can receive key events.
 
- (BOOL) acceptsFirstResponder 
{
    return YES;
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
    [self scrollSelectedModelNodesToVisible];
}

- (void) moveToParent:(id)sender 
{
    id <PSTreeGraphModelNode> modelNode = [self singleSelectedModelNode];
    if (modelNode) {
        if (modelNode != [self modelRoot]) {
            id<PSTreeGraphModelNode> parent = [modelNode parentModelNode];
            if (parent) {
                [self setSelectedModelNodes:[NSSet setWithObject:parent]];
            }
        }
    } else if ([[self selectedModelNodes] count] == 0) {
        // If nothing selected, select root.
        [self setSelectedModelNodes:([self modelRoot] ? [NSSet setWithObject:[self modelRoot]] : nil)];
    }
	
    // Scroll new selection to visible.
    [self scrollSelectedModelNodesToVisible];
}

- (void) moveToNearestChild:(id)sender 
{
    id <PSTreeGraphModelNode> modelNode = [self singleSelectedModelNode];
    if (modelNode) {
        PSBaseSubtreeView *subtreeView = [self subtreeViewForModelNode:modelNode];
        if (subtreeView && [subtreeView isExpanded]) {
            UIView *nodeView = [subtreeView nodeView];
            if (nodeView) {
                CGRect nodeViewFrame = [nodeView frame];
                id <PSTreeGraphModelNode> nearestChild = [subtreeView modelNodeClosestToY:CGRectGetMidY(nodeViewFrame)];
                if (nearestChild) {
                    [self setSelectedModelNodes:[NSSet setWithObject:nearestChild]];
                }
            }
        }
    } else if ([[self selectedModelNodes] count] == 0) {
        // If nothing selected, select root.
        [self setSelectedModelNodes:([self modelRoot] ? [NSSet setWithObject:[self modelRoot]] : nil)];
    }
	
    // Scroll new selection to visible.
    [self scrollSelectedModelNodesToVisible];
}

- (void) moveUp:(id)sender 
{
    [self moveToSiblingByRelativeIndex:-1];
}

- (void) moveDown:(id)sender 
{
    [self moveToSiblingByRelativeIndex:1];
}

- (void) moveLeft:(id)sender 
{
    [self moveToParent:sender];
}

- (void) moveRight:(id)sender 
{
    [self moveToNearestChild:sender];
}

//- (void) keyDown:(NSEvent *)theEvent 
//{
//    NSString *characters = [theEvent characters];
//    if (characters && [characters length] > 0) {
//        switch ([characters characterAtIndex:0]) {
//            case ' ':
//                [self toggleExpansionOfSelectedModelNodes:self];
//                break;
//
//            default:
//                [super keyDown:theEvent];
//                break;
//        }
//    }
//}


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


#pragma mark - Styling

// Getters and setters for TreeGraph's appearance-related properties: colors, metrics, etc.  We could almost 
// auto-generate these using "@synthesize", but we want each setter to automatically mark the affected parts 
// of the TreeGraph (and/or the descendant views that it's responsible for) as needing drawing to reflet the 
// appearance change.  In other respects, these are unremarkable accessor methods that follow standard accessor 
// conventions.


@synthesize connectingLineColor = _connectingLineColor;

- (void) setConnectingLineColor:(UIColor *)newConnectingLineColor 
{
    if (_connectingLineColor != newConnectingLineColor) {
        [_connectingLineColor release];
        _connectingLineColor = [newConnectingLineColor retain];
        [[self rootSubtreeView] recursiveSetConnectorsViewsNeedDisplay];
    }
}

@synthesize contentMargin = _contentMargin;

- (void) setContentMargin:(CGFloat)newContentMargin 
{
    if (_contentMargin != newContentMargin) {
        _contentMargin = newContentMargin;
        [self setNeedsGraphLayout];
        [[self layer] displayIfNeeded];
    }
}

@synthesize parentChildSpacing = _parentChildSpacing;

- (void) setParentChildSpacing:(CGFloat)newParentChildSpacing 
{
    if (_parentChildSpacing != newParentChildSpacing) {
        _parentChildSpacing = newParentChildSpacing;
        [self setNeedsGraphLayout];
        [[self layer] displayIfNeeded];
    }
}

@synthesize siblingSpacing = _siblingSpacing;

- (void) setSiblingSpacing:(CGFloat)newSiblingSpacing 
{
    if (_siblingSpacing != newSiblingSpacing) {
        _siblingSpacing = newSiblingSpacing;
        [self setNeedsGraphLayout];
        [[self layer] displayIfNeeded];
    }
}

@synthesize connectingLineStyle = _connectingLineStyle;

- (void) setConnectingLineStyle:(PSTreeGraphConnectingLineStyle)newConnectingLineStyle 
{
    if (_connectingLineStyle != newConnectingLineStyle) {
        _connectingLineStyle = newConnectingLineStyle;
        [[self rootSubtreeView] recursiveSetConnectorsViewsNeedDisplay];
    }
}

@synthesize connectingLineWidth = _connectingLineWidth;

- (void)setConnectingLineWidth:(CGFloat)newConnectingLineWidth {
    if (_connectingLineWidth != newConnectingLineWidth) {
        _connectingLineWidth = newConnectingLineWidth;
        [[self rootSubtreeView] recursiveSetConnectorsViewsNeedDisplay];
    }
}

@synthesize showsSubtreeFrames = _showsSubtreeFrames;

- (void) setShowsSubtreeFrames:(BOOL)newShowsSubtreeFrames 
{
    if (_showsSubtreeFrames != newShowsSubtreeFrames) {
        _showsSubtreeFrames = newShowsSubtreeFrames;
        [[self rootSubtreeView] resursiveSetSubtreeBordersNeedDisplay];
    }
}

@end


#pragma mark -
@implementation PSBaseTreeGraphView (Internal)


#pragma mark - ModelNode -> SubtreeView Relationship Management

- (PSBaseSubtreeView *) subtreeViewForModelNode:(id)modelNode 
{
    return [_modelNodeToSubtreeViewMapTable objectForKey:modelNode];
}

- (void) setSubtreeView:(PSBaseSubtreeView *)subtreeView forModelNode:(id)modelNode 
{
    [_modelNodeToSubtreeViewMapTable setObject:subtreeView forKey:modelNode];
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