//
//  UserInfoCell.m
//  AnonyFollow
//
//  Created by sonson on 2012/09/02.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "UserInfoCell.h"

#import "TweetContentView.h"

#import "TwitterAccountInfo.h"

@implementation UserInfoCell

- (void)awakeFromNib {
	[super awakeFromNib];
	self.ribbonImageView.hidden = YES;
}

- (void)setAccountInfo:(TwitterAccountInfo *)accountInfo {
	_accountInfo = accountInfo;
	self.tweetContentView.text = accountInfo.description;
	self.nameLabel.text = accountInfo.name;
	self.screenNameLabel.text = accountInfo.screenName;
	
	self.iconImageView.image = accountInfo.iconImage;
}

@end
