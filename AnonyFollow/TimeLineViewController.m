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
	
	if ([info isKindOfClass:[info class]]) {
		for (NSDictionary *tweet in info) {
			TwitterTweet *tweetaa = [[TwitterTweet alloc] init];
			tweetaa.accountInfo = self.accountInfo;
			tweetaa.text = [tweet objectForKey:@"text"];
			[self.tweets addObject:tweetaa];
		}
	}
	[self.tableView reloadData];
}

- (void)didFailedDownloadTask:(DownloadTask*)task {
	DNSLogMethod
}

- (void)didReceiveMemoryWarning
{
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TweetCell *cell = (TweetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    TwitterTweet *tweet = [self.tweets objectAtIndex:indexPath.row];
	cell.tweet = tweet;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
