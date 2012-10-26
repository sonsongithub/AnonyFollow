//
//  AccountsListViewController.m
//  AnonyFollow
//
//  Created by sonson on 2012/10/26.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "AccountsListViewController.h"

#define DEFAULT_ACCOUNTS_LIST_CELL_HEIGHT		58

#import "AppDelegate.h"
#import "TwitterAccountInfo.h"
#import "AccountCell.h"
#import "TimeLineViewController.h"
#import "DownloadQueue.h"
#import "MessageBarButtonItem.h"
#import "SNStatusBarView.h"
#import "SNReachablityChecker.h"
#import "AccountSelectViewController.h"
#import "NSUserDefaults+AnonyFollow.h"

#import <Accounts/Accounts.h>
#import "ACAccountStore+AnonyFollow.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "NSBundle+AnonyFollow.h"

@interface AccountsListViewController ()

@end

@implementation AccountsListViewController

#pragma mark - Thumbnail rendering and downloading

- (void)loadImagesForOnscreenRows {
	DNSLogMethod
    if ([self.accounts count] > 0) {
		NSArray *visibleCells = [self.tableView visibleCells];
		for (AccountCell *cell in visibleCells) {
			TwitterAccountInfo *info = cell.accountInfo;
			
			if (!self.tableView.isDragging && !self.tableView.isDecelerating)
				[info tryToDownloadIconImage];
		}
    }
}

#pragma mark - Lifecylcle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.destinationViewController isKindOfClass:[TimeLineViewController class]]) {
		TimeLineViewController *vc = (TimeLineViewController*)segue.destinationViewController;
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		vc.accountInfo = [self.accounts objectAtIndex:indexPath.row];
	}
}

#pragma mark - Table view data source

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return DEFAULT_ACCOUNTS_LIST_CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.accounts count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
	if (del.checker.status == SNReachablityCheckerReachableViaWiFi || del.checker.status == SNReachablityCheckerReachableViaWWAN) {
		[self performSegueWithIdentifier:@"OpenTimeLine" sender:nil];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AccountCell *cell = (AccountCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
	TwitterAccountInfo *info = [self.accounts objectAtIndex:indexPath.row];
	cell.accountInfo = info;
	
	if (!self.tableView.isDragging && !self.tableView.isDecelerating)
		[info tryToDownloadIconImage];
	
	cell.followButton.tag = indexPath.row;
	
    return cell;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForOnscreenRows];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self.accounts removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
		// [self updateTrashButton];
    }
}

@end
