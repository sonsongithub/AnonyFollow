//
//  TweetContentView.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import "TweetContentView.h"

#import "TwitterTweet.h"

@implementation TweetContentView

- (void)awakeFromNib {
	[super awakeFromNib];
	self.backgroundColor = [UIColor clearColor];
}

- (void)setText:(NSString *)text {
	_text = text;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[self.text drawInRect:rect withFont:[UIFont systemFontOfSize:TIMELINE_VIEW_FONT_SIZE] lineBreakMode:NSLineBreakByCharWrapping];
}

@end
