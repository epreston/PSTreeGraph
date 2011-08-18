//
//  PSHLeafView.h
//  PSHTreeGraph - Example 1
//
//  Created by Ed Preston on 7/26/10.
//  Copyright 2010 Preston Software. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "PSBaseLeafView.h"

@interface PSHLeafView : PSBaseLeafView {

	// Interface
	UIButton *expandButton;
	UILabel *titleLabel;
	UILabel *detailLabel;
}

@property(assign) IBOutlet UIButton *expandButton;
@property(assign) IBOutlet UILabel *titleLabel;
@property(assign) IBOutlet UILabel *detailLabel;

@end
