//
//  PSHLeafView.h
//  PSHTreeGraph - Example 1
//
//  Created by Ed Preston on 7/26/10.
//  Copyright 2010 Preston Software. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "PSBaseLeafView.h"

@interface PSHLeafView : PSBaseLeafView
{

@private

	// Interface
	UIButton *expandButton_;
	UILabel *titleLabel_;
	UILabel *detailLabel_;
}

@property (nonatomic, assign) IBOutlet UIButton *expandButton;
@property (nonatomic, assign) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) IBOutlet UILabel *detailLabel;

@end
