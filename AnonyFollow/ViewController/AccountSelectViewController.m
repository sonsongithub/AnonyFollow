//
//  AccountSelectViewController.m
//  AnonyFollow
//
//  Created by sonson on 2012/09/01.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "AccountSelectViewController.h"

#import "TwitterAccountInfo.h"
#import "AccountCell.h"
#import "NSUserDefaults+AnonyFollow.h"

#define DEFAULT_ACCOUNT_SELECT_VIEW_CELL_HEIGHT		58

@interface AccountSelectViewController ()

@end

@implementation AccountSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.accounts = [NSMutableArray array];
	
	for (NSString* username in self.userNameList) {
		TwitterAccountInfo *info = [[TwitterAccountInfo alloc] init];
		info.screenName = username;
		[self.accounts addObject:info];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return DEFAULT_ACCOUNT_SELECT_VIEW_CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	AccountCell *cell = (AccountCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
	NSString *currentTwitterUserName = [[NSUserDefaults standardUserDefaults] objectForKey:kAnonyFollowCurrentTwitterUserName];
	
    // Configure the cell...
	TwitterAccountInfo *info = [self.accounts objectAtIndex:indexPath.row];
	cell.accountInfo = info;
	
	if ([info.screenName isEqualToString:currentTwitterUserName])
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	if (!self.tableView.isDragging && !self.tableView.isDecelerating)
		[info tryToDownloadIconImage];	
    return cell;
}

#pragma mark - Thumbnail rendering and downloading

- (void)loadImagesForOnscreenRows {
	//DNSLogMethod
    if ([self.accounts count] > 0) {
		NSArray *visibleCells = [self.tableView visibleCells];
		for (AccountCell *cell in visibleCells) {
			TwitterAccountInfo *info = cell.accountInfo;
			
			if (!self.tableView.isDragging && !self.tableView.isDecelerating)
				[info tryToDownloadIconImage];
		}
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForOnscreenRows];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	TwitterAccountInfo *info = [self.accounts objectAtIndex:indexPath.row];
		
	[[NSUserDefaults standardUserDefaults] setObject:info.screenName forKey:kAnonyFollowCurrentTwitterUserName];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self.tableView reloadData];
}

@end
