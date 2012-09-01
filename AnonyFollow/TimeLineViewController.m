//
//  TimeLineViewController.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "TimeLineViewController.h"

#import "DownloadQueue.h"
#import "TwitterAccountInfo.h"
#import "TwitterTweet.h"
#import "TweetCell.h"

@interface TimeLineViewController ()

@end

@implementation TimeLineViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.tweets = [NSMutableArray array];
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[DownloadQueue sharedInstance] clearQueue];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	
	DNSLog(@"%@", self.accountInfo);
	DNSLog(@"%@", self.accountInfo.iconImage);
	
	DownloadTask *task = [self.accountInfo taskForUserTimeline];
	task.delegate = self;
	
	[[DownloadQueue sharedInstance] addTask:task];
}

- (void)didDownloadTask:(DownloadTask*)task {
	NSError *error = nil;
	NSArray *info = [NSJSONSerialization JSONObjectWithData:task.data options:0 error:&error];
	DNSLog(@"%@", [error localizedDescription]);
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"ccc MMM dd HH:mm:ss z yyyy"];
	
	if ([info isKindOfClass:[info class]]) {
		for (NSDictionary *tweet in info) {
			TwitterTweet *tweetaa = [[TwitterTweet alloc] init];
			tweetaa.accountInfo = self.accountInfo;
			tweetaa.text = [tweet objectForKey:@"text"];
			
			tweetaa.created_at = [formatter dateFromString:[tweet objectForKey:@"created_at"]];
			
			[self.tweets addObject:tweetaa];
			
			tweetaa.contentSize = [TwitterTweet sizeOfText:tweetaa.text withWidth:254 font:[UIFont systemFontOfSize:12]];
			
		}
	}
	[self.tableView reloadData];
}

- (void)didFailedDownloadTask:(DownloadTask*)task {
	DNSLogMethod
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.tweets count];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	TwitterTweet *tweet = [self.tweets objectAtIndex:indexPath.row];
	return [tweet height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    TweetCell *cell = (TweetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    TwitterTweet *tweet = [self.tweets objectAtIndex:indexPath.row];
	cell.tweet = tweet;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end
