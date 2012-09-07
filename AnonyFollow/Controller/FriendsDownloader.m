//
//  FriendsDownloader.m
//  AnonyFollow
//
//  Created by sonson on 2012/09/02.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "FriendsDownloader.h"

#import "DownloadQueue.h"

@implementation FriendsDownloader

- (void)startWithScreenName:(NSString*)screenName completion:(void (^)(BOOL))blk {
	self.blk = blk;
	self.screenName = screenName;
	
	DownloadTask *task = [self taskWithScreenName:self.screenName cursor:@"-1"];
	task.delegate = self;
	[[DownloadQueue sharedInstance] addTask:task];
}

- (DownloadTask*)taskWithScreenName:(NSString*)screenName cursor:(NSString*)cursor {
	NSString *URLString = [NSString stringWithFormat:@"https://api.twitter.com/1/friends/ids.json?cursor=%@&screen_name=%@", cursor, screenName];
	DownloadTask *task = [[DownloadTask alloc] init];
	task.request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
	return task;
}

- (void)didDownloadTask:(DownloadTask *)task {
	NSError *error = nil;
	NSDictionary *info = [NSJSONSerialization JSONObjectWithData:task.data options:0 error:&error];
	DNSLog(@"%@", info);
	
	NSString *next = [info objectForKey:@"next_cursor"];
	
	if ([next integerValue] > 0) {
		DownloadTask *new_task = [self taskWithScreenName:self.screenName cursor:next];
		new_task.delegate = self;
		[[DownloadQueue sharedInstance] addTask:new_task];
	}
}

- (void)didFailedDownloadTask:(DownloadTask *)task {
	self.blk(NO);
}

@end
