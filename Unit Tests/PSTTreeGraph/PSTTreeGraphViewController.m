//
//  PSTTreeGraphViewController.m
//  PSTTreeGraph
//
//  Created by Ed Preston on 26/08/11.
//  Copyright 2011 Preston Software. All rights reserved.
//

#import "PSTTreeGraphViewController.h"

@implementation PSTTreeGraphViewController


#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

#pragma mark - View Creation and Initializer

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
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
    
    [super viewDidUnload];
}

@end
