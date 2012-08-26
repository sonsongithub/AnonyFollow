//
//  TweetCell.h
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TweetContentView;

@class TwitterTweet;

@interface TweetCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *iconImageView;
@property (nonatomic, strong) IBOutlet UIImageView *vacantImageView;
@property (nonatomic, strong) IBOutlet UIImageView *ribbonImageView;

@property (nonatomic, strong) IBOutlet TweetContentView *tweetContentView;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;

@property (nonatomic, strong) TwitterTweet *tweet;
@end
