//
//  LoadingView.m
//  AnonyFollow
//
//  Created by sonson on 2012/09/02.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

- (void)awakeFromNib {
	[super awakeFromNib];
    [[NSBundle mainBundle] loadNibNamed:@"LoadingView" owner:self options:nil];
	[self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
	[self.indicator startAnimating];
	
	[self addSubview:self.contentView];
}

- (void)layoutSubviews {
	self.contentView.center = self.center;
	self.frame = self.superview.frame;
	[super layoutSubviews];
}

@end
