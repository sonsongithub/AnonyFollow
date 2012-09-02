//
//  UserInfoCell.h
//  AnonyFollow
//
//  Created by sonson on 2012/09/02.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TwitterAccountInfo;
@class TweetContentView;

@interface UserInfoCell : UITableViewCell

@property (nonatomic, strong) TwitterAccountInfo *accountInfo;

@property (nonatomic, strong) IBOutlet UIImageView *iconImageView;
@property (nonatomic, strong) IBOutlet UIImageView *vacantImageView;
@property (nonatomic, strong) IBOutlet UIImageView *ribbonImageView;

@property (nonatomic, strong) IBOutlet TweetContentView *tweetContentView;
@property (nonatomic, strong) IBOutlet UILabel *line1;
@property (nonatomic, strong) IBOutlet UILabel *line2;

@end
