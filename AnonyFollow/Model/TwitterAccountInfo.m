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

#import "NSData+MD5.h"

@implementation TwitterAccountInfo

#pragma mark - Manages cache of thumbnails and sssp images.

+ (UIImage*)cacheImageWithURLString:(NSString*)URLString {
	
	NSString *hash = [URLString md5HexHash];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cacheDirectory = [paths objectAtIndex:0];
	NSString *thumbnailCacheDirectory = [cacheDirectory stringByAppendingPathComponent:@"icon_image"];
	
	NSString *cacheFilePath = [thumbnailCacheDirectory stringByAppendingPathComponent:hash];
	
	return [UIImage imageWithContentsOfFile:cacheFilePath];
}

+ (BOOL)writeCacheImageWithData:(NSData*)data URLString:(NSString*)URLString {
	
	NSString *hash = [URLString md5HexHash];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cacheDirectory = [paths objectAtIndex:0];
	NSString *thumbnailCacheDirectory = [cacheDirectory stringByAppendingPathComponent:@"icon_image"];
	
	[[NSFileManager defaultManager] createDirectoryAtPath:thumbnailCacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	
	NSString *cacheFilePath = [thumbnailCacheDirectory stringByAppendingPathComponent:hash];
	
	return [data writeToFile:cacheFilePath atomically:NO];
}

- (void)dealloc {
	[[DownloadQueue sharedInstance] removeTasksOfDelegate:self];
}

- (DownloadTask*)taskForUserTimeline {
	NSString *URLString = [NSString stringWithFormat:@"https://api.twitter.com/1/statuses/user_timeline.json?include_entities=true&include_rts=true&screen_name=%@", self.screenName];
	DownloadTask *task = [[DownloadTask alloc] init];
	task.request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
	return task;
}

- (DownloadTask*)taskForUserInfo {
	NSString *URLString = [NSString stringWithFormat:@"https://api.twitter.com/1/users/show.json?include_entities=true&screen_name=%@", self.screenName];
	DownloadTask *task = [[DownloadTask alloc] init];
	task.request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
	return task;
}

//https://api.twitter.com/1/users/show.json?screen_name=TwitterAPI&include_entities=true

- (BOOL)tryToDownloadIconImage {
	NSString *URLString = [NSString stringWithFormat:@"https://api.twitter.com/1/users/profile_image?screen_name=%@&size=bigger", self.screenName];
	
	UIImage *cache = [TwitterAccountInfo cacheImageWithURLString:URLString];
	
	if (cache) {
		self.iconImage = cache;
		[[NSNotificationCenter defaultCenter] postNotificationName:AccountCellUpdateNotification object:nil userInfo:nil];
		return NO;
	}
	
	if (self.iconImage)
		return NO;
	
	[[DownloadQueue sharedInstance] removeTasksOfDelegate:self];
	
	
	DownloadTask *task = [[DownloadTask alloc] init];
	task.request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
	task.delegate = self;
	[[DownloadQueue sharedInstance] addTask:task];
	
	return YES;
}

- (void)didDownloadTask:(DownloadTask*)task {
	UIImage *image = [UIImage imageWithData:task.data];
	self.iconImage = image;
	DNSLog(@"%@", image);
	[TwitterAccountInfo writeCacheImageWithData:task.data URLString:[task.request.URL absoluteString]];
	[[NSNotificationCenter defaultCenter] postNotificationName:AccountCellUpdateNotification object:nil userInfo:nil];
}

- (void)didFailedDownloadTask:(DownloadTask*)task {
}

@end
