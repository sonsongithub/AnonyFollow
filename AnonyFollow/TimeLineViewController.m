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

#import "ACAccountStore+AnonyFollow.h"
#import <Social/Social.h>

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

- (IBAction)follow:(id)sender {
	[self followOnTwitter:self.accountInfo.screenName];
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
			
			tweetaa.contentSize = [TwitterTweet sizeOfText:tweetaa.text withWidth:227 font:[UIFont systemFontOfSize:12]];
			
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
						[[NSNotificationCenter defaultCenter] postNotificationName:@"didFollowUser" object:nil userInfo:[NSDictionary dictionaryWithObject:self.accountInfo.screenName forKey:@"userName"]];
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
