//
//  TweetCell.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import "TweetCell.h"

#import "TwitterAccountInfo.h"
#import "TwitterTweet.h"
#import "TweetContentView.h"

@implementation TweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)update:(NSNotification*)notification {
	self.iconImageView.image = self.tweet.accountInfo.iconImage;
	self.vacantImageView.hidden = (self.tweet.accountInfo.iconImage != nil);
}

- (void)setTweet:(TwitterTweet *)tweet {
	_tweet = tweet;
	self.tweetContentView.tweet = self.tweet;
	self.dateLabel.text = [self.tweet.created_at description];
	[self update:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
