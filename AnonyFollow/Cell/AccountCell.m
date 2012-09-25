//
//  AccountCell.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import "AccountCell.h"

#import "TwitterAccountInfo.h"
#import "DownloadQueue.h"
#import "AppDelegate.h"
#import "SNReachablityChecker.h"

NSString *AccountCellUpdateNotification = @"AccountCellUpdateNotification";

@implementation AccountCell

- (void)update:(NSNotification*)notification {
	self.iconImageView.image = self.accountInfo.iconImage;

	self.vacantImageView.hidden = (self.accountInfo.iconImage != nil);
		
	self.screenNameLabel.text = self.accountInfo.screenName;
}

- (void)setAccountInfo:(TwitterAccountInfo *)accountInfo {
	_accountInfo = accountInfo;
	
	[self update:nil];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)startLoading {
	self.followButton.hidden = YES;
	self.indicatorView.hidden = NO;
	[self.indicatorView startAnimating];
}

- (void)stopLoading {
	AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
	self.followButton.hidden = !(del.checker.status == SNReachablityCheckerReachableViaWiFi || del.checker.status == SNReachablityCheckerReachableViaWWAN);
	[self.indicatorView stopAnimating];
	self.indicatorView.hidden = YES;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	self.indicatorView.hidden = YES;
	self.ribbonImageView.hidden = YES;
	[self prepareForReuse];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:AccountCellUpdateNotification object:nil];
}

- (void)prepareForReuse {
	[super prepareForReuse];
	
	AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
	self.followButton.hidden = !(del.checker.status == SNReachablityCheckerReachableViaWiFi || del.checker.status == SNReachablityCheckerReachableViaWWAN);
	self.selectionStyle = (del.checker.status == SNReachablityCheckerReachableViaWiFi || del.checker.status == SNReachablityCheckerReachableViaWWAN) ? UITableViewCellSelectionStyleBlue : UITableViewCellEditingStyleNone;
	
	[[DownloadQueue sharedInstance] removeTasksOfDelegate:self];
	
	UIImage *image = [UIImage imageNamed:@"PurchasePlusButton.png"];
	UIImage *strechable = [image stretchableImageWithLeftCapWidth:10 topCapHeight:10];
	[self.followButton setBackgroundImage:strechable forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setEditing:(BOOL)editing {
	[super setEditing:editing];
	
	AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
	if (del.checker.status == SNReachablityCheckerReachableViaWiFi || del.checker.status == SNReachablityCheckerReachableViaWWAN) {
		self.followButton.hidden = editing;
	}
	else
		self.followButton.hidden = YES;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
	if (del.checker.status == SNReachablityCheckerReachableViaWiFi || del.checker.status == SNReachablityCheckerReachableViaWWAN) {
		self.followButton.hidden = editing;
	}
	else
		self.followButton.hidden = YES;
}

@end
