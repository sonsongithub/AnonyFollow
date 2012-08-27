//
//  MainListViewController.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import "MainListViewController.h"

@interface MainListViewController ()

@end

#import "AppDelegate.h"
#import "TwitterAccountInfo.h"
#import "AccountCell.h"
#import "TimeLineViewController.h"
#import "DownloadQueue.h"
#import "LockScreenView.h"

#import "CBAdvertizer.h"
#import "CBScanner.h"

#import <Accounts/Accounts.h>

@implementation MainListViewController

- (void)enableBroadcasting {
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	self.segmentedControl.userInteractionEnabled = NO;
	
	[accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
		if(granted) {
			NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
			if ([accountsArray count] > 0) {
				// Grab the initial Twitter account to tweet from.
				ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
				dispatch_async(dispatch_get_main_queue(), ^(void) {
					
					self.advertizer = [[CBAdvertizer alloc] initWithUserName:twitterAccount.username];
					self.scanner = [[CBScanner alloc] initinitWithDelegate:nil ServiceUUIDStr:nil];
					
					AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
					[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
					[del.barView setColor:[UIColor greenColor]];
					[del.barView setMessage:NSLocalizedString(@"Broadcasting...", nil)];
				});
			}
			else{
				NSLog(@"No Twitter Account");
				self.segmentedControl.selectedSegmentIndex = 0;
			}
		}else{
			NSLog(@"accountStore accesss denied");
			self.segmentedControl.selectedSegmentIndex = 0;
		}
		self.segmentedControl.userInteractionEnabled = YES;
	}];
}

- (IBAction)select:(id)sender {
	UISegmentedControl *control = self.segmentedControl;
	if (control.selectedSegmentIndex == 0) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	}
	if (control.selectedSegmentIndex == 1) {
		[self enableBroadcasting];
	}
	if (control.selectedSegmentIndex == 2) {
		[self enableBroadcasting];
	}
}

- (IBAction)trash:(id)sender {
}

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
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	
	self.accounts = [NSMutableArray array];
	
	NSArray *samples = [NSArray arrayWithObjects:
						@"sonson_twit",
						@"fladdict",
						@"hakochin",
						@"iakiyama",
						@"soendoen",
						@"yazhuhua",
						@"dancingpandor",
						@"tyfk",
						@"tokyopengwyn",
						@"blogranger",
						@"rsebbe",
						@"goando",
						@"kentakeuchi2003",
						@"keita_f",
						nil
						];
	
	for (NSString *account in samples) {
		TwitterAccountInfo *info = [[TwitterAccountInfo alloc] init];
		info.screenName = account;
		[self.accounts addObject:info];
		
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.destinationViewController isKindOfClass:[TimeLineViewController class]]) {
		TimeLineViewController *vc = (TimeLineViewController*)segue.destinationViewController;
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		vc.accountInfo = [self.accounts objectAtIndex:indexPath.row];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[DownloadQueue sharedInstance] clearQueue];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self loadImagesForOnscreenRows];
	
	[UIView animateWithDuration:0.4 animations:^(void){
		self.navigationController.view.frame = CGRectMake(0, 20, 320, 460);
	}];
	
//	[[[UIApplication sharedApplication] keyWindow] addSubview:self.lockScreenView];
//	self.lockScreenView.frame = self.navigationController.view.frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 58;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AccountCell *cell = (AccountCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
	TwitterAccountInfo *info = [self.accounts objectAtIndex:indexPath.row];
	cell.accountInfo = info;
	
	if (!self.tableView.isDragging && !self.tableView.isDecelerating)
		[info tryToDownloadIconImage];
	
    return cell;
}

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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForOnscreenRows];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
}

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
