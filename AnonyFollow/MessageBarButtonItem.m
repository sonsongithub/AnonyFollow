//
//  MessageBarButtonItem.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/28.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "MessageBarButtonItem.h"

@implementation MessageBarButtonItem

- (id)initWithCoder:(NSCoder *)aDecoder {
	
	self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
	[self.label setBackgroundColor:[UIColor clearColor]];
	self.label.textColor = [UIColor whiteColor];
	self.label.shadowColor = [UIColor blackColor];
	self.label.shadowOffset = CGSizeMake(0, -1);
	self.label.text = @"sonson_twit";
	self.label.font = [UIFont boldSystemFontOfSize:16];
	self.label.textAlignment = NSTextAlignmentCenter;
	
	self = [super initWithCustomView:self.label];
	
	return self;
}

@end
