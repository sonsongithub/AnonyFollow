//
//  TwitterAccountInfo.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import "TwitterAccountInfo.h"

#import "DownloadQueue.h"

#import "AccountCell.h"

@implementation TwitterAccountInfo

- (BOOL)tryToDownloadIconImage {
	
	if (self.iconImage)
		return NO;
	
	[[DownloadQueue sharedInstance] removeTasksOfDelegate:self];
	
	NSString *URLString = [NSString stringWithFormat:@"https://api.twitter.com/1/users/profile_image?screen_name=%@&size=bigger", self.screenName];
	DownloadTask *task = [[DownloadTask alloc] init];
	task.request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
	task.delegate = self;
	[[DownloadQueue sharedInstance] addTask:task];
	
//	if (!self.tableView.isDragging && !self.tableView.isDecelerating) {
//	}
	return YES;
}

- (void)didDownloadTask:(DownloadTask*)task {
	UIImage *image = [UIImage imageWithData:task.data];
	self.iconImage = image;
	DNSLog(@"%@", image);
	[[NSNotificationCenter defaultCenter] postNotificationName:AccountCellUpdateNotification object:nil userInfo:nil];
}

- (void)didFailedDownloadTask:(DownloadTask*)task {
}

@end
