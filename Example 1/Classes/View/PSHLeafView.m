//
//  PSHLeafView.m
//  PSHTreeGraph - Example 1
//
//  Created by Ed Preston on 7/26/10.
//  Copyright 2010 Preston Software. All rights reserved.
//


#import "PSHLeafView.h"


@implementation PSHLeafView

@synthesize expandButton, titleLabel, detailLabel;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


@end
