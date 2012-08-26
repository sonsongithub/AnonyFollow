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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	self.backgroundColor = [UIColor clearColor];
}

- (void)setTweet:(TwitterTweet *)tweet {
	_tweet = tweet;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[self.tweet.text drawInRect:rect withFont:[UIFont systemFontOfSize:12] lineBreakMode:NSLineBreakByCharWrapping];
}

@end
