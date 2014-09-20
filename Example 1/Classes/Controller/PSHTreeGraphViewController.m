//
//  PSHTreeGraphViewController.m
//  PSHTreeGraph - Example 1
//
//  Created by Ed Preston on 7/25/10.
//  Copyright Preston Software 2010. All rights reserved.
//


#import "PSHTreeGraphViewController.h"

#import "PSBaseTreeGraphView.h"
#import "MyLeafView.h"

#import "ObjCClassWrapper.h"



@implementation PSHTreeGraphViewController


#pragma mark - Property Accessors

- (void) setRootClassName:(NSString *)newRootClassName
{
    NSParameterAssert(newRootClassName != nil);

    if (![_rootClassName isEqualToString:newRootClassName]) {
        _rootClassName = [newRootClassName copy];

        _treeGraphView.treeGraphOrientation  = PSTreeGraphOrientationStyleHorizontalFlipped;

        // Get an ObjCClassWrapper for the named Objective-C Class, and set it as the TreeGraph's root.
        [_treeGraphView setModelRoot:[ObjCClassWrapper wrapperForClassNamed:_rootClassName]];
    }
}


#pragma mark - View Creation and Initializer

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad
{
    [super viewDidLoad];

	// Set the delegate to self.
	[self.treeGraphView setDelegate:self];

	// Specify a .nib file for the TreeGraph to load each time it needs to create a new node view.
    [self.treeGraphView setNodeViewNibName:@"ObjCClassTreeNodeView"];

    // Specify a starting root class to inspect on launch.
    
    [self setRootClassName:@"UIControl"];
    
    // The system includes some other abstract base classes that are interesting:
    // [self setRootClassName:@"CAAnimation"];

}

// Override to allow orientations other than the default portrait orientation.
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                                         duration:(NSTimeInterval)duration
{
	// Keep the view in sync
	[self.treeGraphView parentClipViewDidResize:nil];
}


#pragma mark - TreeGraph Delegate

-(void) configureNodeView:(UIView *)nodeView
            withModelNode:(id <PSTreeGraphModelNode> )modelNode
{
    NSParameterAssert(nodeView != nil);
    NSParameterAssert(modelNode != nil);

	// NOT FLEXIBLE: treat it like a model node instead of the interface.
	ObjCClassWrapper *objectWrapper = (ObjCClassWrapper *)modelNode;
	MyLeafView *leafView = (MyLeafView *)nodeView;

	// button
	if ( [[objectWrapper childModelNodes] count] == 0 ) {
		[leafView.expandButton setHidden:YES];
	}

	// labels
	leafView.titleLabel.text	= [objectWrapper name];
	leafView.detailLabel.text	= [NSString stringWithFormat:@"%zd bytes",
                                   [objectWrapper wrappedClassInstanceSize]];

}


#pragma mark - Resouce Management

- (void) didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void) viewDidUnload
{
    // Depricated in iOS 6.0  -  This method is never called.
    
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    
    [super viewDidUnload];
}


@end
