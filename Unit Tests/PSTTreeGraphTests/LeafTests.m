//
//  LeafTests.m
//  PSTTreeGraphTests
//
//  Created by Ed Preston on 26/08/11.
//  Copyright 2011 Preston Software. All rights reserved.
//

#import "LeafTests.h"

@implementation LeafTests

- (void)setUp
{
    [super setUp];

    // Set-up code here.


    aLeaf = [[PSBaseLeafView alloc] initWithFrame:CGRectZero];
    STAssertNotNil(aLeaf, @"Couldn't create leaf view.");


}

- (void)tearDown
{
    // Tear-down code here.

    [aLeaf release];

    [super tearDown];
}

- (void)testSelectionState
{
    STAssertFalse(aLeaf.showingSelected, @"Leaf nodes should not be selected by default.");

    aLeaf.showingSelected = YES;
    STAssertTrue(aLeaf.showingSelected, @"showingSelected property assignment failed.");

    aLeaf.showingSelected = NO;
    STAssertFalse(aLeaf.showingSelected, @"showingSelected property assignment failed.");
}

@end
