//
//  PSHLeafView.m
//  PSHTreeGraph - Example 1
//
//  Created by Ed Preston on 7/26/10.
//  Copyright 2010 Preston Software. All rights reserved.
//


#import "PSHLeafView.h"


@implementation PSHLeafView

@synthesize expandButton = expandButton_;
@synthesize titleLabel = titleLabel_;
@synthesize detailLabel = detailLabel_;


#pragma mark - NSCoding

- (id) initWithCoder:(NSCoder *)decoder 
{
    self = [super initWithCoder:decoder];
    if (self) {
        
        // Initialization code, leaf views are always loaded from the corresponding XIB.
        // Be sure to set the view class to your subclass in interface builder.
        
        // Example: Inverse the color scheme
        
//        self.fillColor = [UIColor yellowColor];
//        self.selectionColor = [UIColor orangeColor];
        
    }
    return self;
}


#pragma mark - Resource Management

- (void) dealloc 
{
    [super dealloc];
}

@end
