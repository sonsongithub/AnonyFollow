//
//  TimeLineViewController.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "TimeLineViewController.h"

#import "MainListViewController.h"
#import "DownloadQueue.h"
#import "TwitterAccountInfo.h"
#import "TwitterTweet.h"
#import "TweetCell.h"
#import "ACAccountStore+AnonyFollow.h"
#import "UserInfoCell.h"
#import "TweetContentView.h"

#import <Social/Social.h>

// parameters for rendering
#define OFFSET_ACCOUNT_INFO_CELL_HEIGHT		66
#define DEFAULT_ACCOUNT_INFO_CELL_HEIGHT	68
#define DEFAULT_LOADING_TWEET_CELL_HEIGHT	44

#define WIDTH_FOR_ACCOUNT_DESCRIPTION		288
#define WIDTH_FOR_TWEET_DESCRIPTION			227

// download identifier
NSString *kTaskForUserTimeline = @"taskForUserTimeline";
NSString *kTaskForUserInfo = @"taskForUserInfo";

@interface TimeLineViewController ()

@end

@implementation TimeLineViewController

- (IBAction)follow:(id)sender {
	[self followOnTwitter:self.accountInfo.screenName];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tweets = [NSMutableArray array];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[DownloadQueue sharedInstance] clearQueue];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.title = [NSString stringWithFormat:NSLocalizedString(@"@%@", nil), self.accountInfo.screenName];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	DNSLog(@"%@", self.accountInfo);
	DNSLog(@"%@", self.accountInfo.iconImage);
	{
		DownloadTask *task = [self.accountInfo taskForUserInfo];
		task.delegate = self;
		task.identifier = kTaskForUserInfo;
		[[DownloadQueue sharedInstance] addTask:task];
	}
	{
		DownloadTask *task = [self.accountInfo taskForUserTimeline];
		task.delegate = self;
		task.identifier = kTaskForUserTimeline;
		[[DownloadQueue sharedInstance] addTask:task];
	}
}

#pragma mark - DownloadTask

- (void)didDownloadTask:(DownloadTask*)task {
	if ([task.identifier isEqualToString:kTaskForUserTimeline]) {
		self.didFinishDownloadingRecentTweet = YES;
		NSError *error = nil;
		NSArray *info = [NSJSONSerialization JSONObjectWithData:task.data options:0 error:&error];
		DNSLog(@"%@", [error localizedDescription]);
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
		[formatter setDateFormat:@"ccc MMM dd HH:mm:ss z yyyy"];
		
		NSDateFormatter *output_formatter = [[NSDateFormatter alloc] init];
		[output_formatter setDateStyle:NSDateFormatterMediumStyle];
		[output_formatter setTimeStyle:NSDateFormatterMediumStyle];
		
		if ([info isKindOfClass:[info class]]) {
			for (NSDictionary *tweet in info) {
				TwitterTweet *tweetaa = [[TwitterTweet alloc] init];
				tweetaa.accountInfo = self.accountInfo;
				tweetaa.text = [tweet objectForKey:@"text"];
				
				tweetaa.created_at = [formatter dateFromString:[tweet objectForKey:@"created_at"]];
				
				tweetaa.created_at_string = [output_formatter stringFromDate:tweetaa.created_at];
				
				[self.tweets addObject:tweetaa];
				
				tweetaa.contentSize = [TwitterTweet sizeOfText:tweetaa.text withWidth:WIDTH_FOR_TWEET_DESCRIPTION font:[UIFont systemFontOfSize:TIMELINE_VIEW_FONT_SIZE]];
				
			}
		}
		[self.tableView reloadData];
	}
	else if ([task.identifier isEqualToString:kTaskForUserInfo]) {
		self.didFinishDownloadingAccountInfo = YES;
		NSError *error = nil;
		NSDictionary *info = [NSJSONSerialization JSONObjectWithData:task.data options:0 error:&error];
		DNSLog(@"%@", info);
		
		self.accountInfo.name = [info objectForKey:@"name"];
		self.accountInfo.description = [info objectForKey:@"description"];
		
		[self.tableView reloadData];
	}
	
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		if ([[DownloadQueue sharedInstance].queue count] == 0)
			[self.view bringSubviewToFront:self.tableView];
	});
}

- (void)didFailedDownloadTask:(DownloadTask*)task {
	DNSLogMethod
	if ([task.identifier isEqualToString:kTaskForUserTimeline])
		self.didFinishDownloadingRecentTweet = YES;
	else if ([task.identifier isEqualToString:kTaskForUserInfo])
		self.didFinishDownloadingAccountInfo = YES;
	
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		if ([[DownloadQueue sharedInstance].queue count] == 0)
			[self.view bringSubviewToFront:self.tableView];
	});
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 1;
	}
	if (section == 1) {
		if (self.didFinishDownloadingRecentTweet)
			return [self.tweets count];
		else
			return 1;
	}
	return 0;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if ([self.accountInfo.description length]) {
			CGSize size = [TwitterTweet sizeOfText:self.accountInfo.description withWidth:WIDTH_FOR_ACCOUNT_DESCRIPTION font:[UIFont systemFontOfSize:TIMELINE_VIEW_FONT_SIZE]];
			return size.height + OFFSET_ACCOUNT_INFO_CELL_HEIGHT;
		}
		else
			return DEFAULT_ACCOUNT_INFO_CELL_HEIGHT;
	}
	if (indexPath.section == 1) {
		if (self.didFinishDownloadingRecentTweet) {
			TwitterTweet *tweet = [self.tweets objectAtIndex:indexPath.row];
			return [tweet height];
		}
		else
			return DEFAULT_LOADING_TWEET_CELL_HEIGHT;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0)
		return nil;
	if (section == 1) {
		if (self.didFinishDownloadingRecentTweet) {
			if ([self.tweets count] > 0)
				return NSLocalizedString(@"Recent tweets", nil);
			else
				return NSLocalizedString(@"No recent tweets", nil);
		}
		else {
			return NSLocalizedString(@"Recent tweets", nil);
		}
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		UserInfoCell *cell = (UserInfoCell*)[tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
		cell.accountInfo = self.accountInfo;
		cell.activityIndicatorView.hidden = self.didFinishDownloadingAccountInfo;
		return cell;
	}
	if (indexPath.section == 1) {
		if (self.didFinishDownloadingRecentTweet) {
			TweetCell *cell = (TweetCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
			TwitterTweet *tweet = [self.tweets objectAtIndex:indexPath.row];
			cell.tweet = tweet;
			return cell;
		}
		else {
			UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
			return cell;
		}
	}
	return nil;
}

- (void)followOnTwitter:(NSString*)userName {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
			ACAccount *account = [accountStore twitterCurrentAccount];
			
			if (account == nil)
				return;
			
			NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
			[tempDict setValue:userName forKey:@"screen_name"];
			
			SLRequest *postRequest;
			[tempDict setValue:@"true" forKey:@"follow"];
			postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1/friendships/create.json"] parameters:tempDict];
			
			[postRequest setAccount:account];
			[postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
				if ([urlResponse statusCode] == 403 ||  [urlResponse statusCode] == 200) {
					dispatch_async(dispatch_get_main_queue(), ^(void){
						[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserInfoUserNameKey object:nil userInfo:[NSDictionary dictionaryWithObject:self.accountInfo.screenName forKey:kNotificationUserInfoUserNameKey]];
						[self.navigationController popViewControllerAnimated:YES];
					});
				}
				else {
					// Error?
					DNSLog(@"Error?");
				}
			}];
        }
    }];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end
