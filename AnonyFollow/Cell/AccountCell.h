//
//  AccountCell.h
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TwitterAccountInfo;

@interface AccountCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *iconImageView;
@property (nonatomic, strong) IBOutlet UIImageView *vacantImageView;
@property (nonatomic, strong) IBOutlet UIImageView *ribbonImageView;

@property (nonatomic, strong) IBOutlet UIButton *followButton;
@property (nonatomic, strong) IBOutlet UILabel *screenNameLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) TwitterAccountInfo *accountInfo;

- (void)startLoading;
- (void)stopLoading;

@end
