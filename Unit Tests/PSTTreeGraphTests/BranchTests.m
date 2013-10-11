//
//  BranchTests.m
//  PSTTreeGraphTests
//
//  Created by Ed Preston on 26/08/11.
//  Copyright 2011 Preston Software. All rights reserved.
//

#import "BranchTests.h"

@implementation BranchTests

- (void)setUp
{
    [super setUp];

    // Set-up code here.

    aBranch = [[PSBaseBranchView alloc] initWithFrame:CGRectZero];
    XCTAssertNotNil(aBranch, @"Couldn't create branch view.");

}

- (void)tearDown
{
    // Tear-down code here.

    [aBranch release];

    [super tearDown];
}

- (void)testExample
{
//    STFail(@"Unit tests are not implemented yet in PSTTreeGraphTests");
}

@end
