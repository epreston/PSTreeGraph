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
    XCTAssertNotNil(aLeaf, @"Couldn't create leaf view.");


}

- (void)tearDown
{
    // Tear-down code here.

    [aLeaf release];

    [super tearDown];
}

- (void)testSelectionState
{
    XCTAssertFalse(aLeaf.showingSelected, @"Leaf nodes should not be selected by default.");

    aLeaf.showingSelected = YES;
    XCTAssertTrue(aLeaf.showingSelected, @"showingSelected property assignment failed.");

    aLeaf.showingSelected = NO;
    XCTAssertFalse(aLeaf.showingSelected, @"showingSelected property assignment failed.");
}

@end
