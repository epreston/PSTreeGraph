//
//  PSHTreeGraphView.m
//  PSHTreeGraph - Example 1
//
//  Created by Ed Preston on 7/25/10.
//  Copyright 2010 Preston Software. All rights reserved.
//


#import "PSHTreeGraphView.h"


@implementation PSHTreeGraphView


#pragma mark - UIView

- (id) initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {

        // Initialization code when created dynamicly

    }
    return self;
}


#pragma mark - NSCoding

- (id) initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {

        // Initialization code when loaded from XIB (this example)

        // Example: Set a larger content margin than default.

//        self.contentMargin = 60.0;

    }
    return self;
}

#pragma mark - Resource Management

- (void) dealloc
{
    [super dealloc];
}

@end
