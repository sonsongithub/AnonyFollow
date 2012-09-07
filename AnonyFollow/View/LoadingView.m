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
	[self setBackgroundColor:[UIColor clearColor]];
	[self.indicator startAnimating];
	
	[self addSubview:self.contentView];
}

@end
