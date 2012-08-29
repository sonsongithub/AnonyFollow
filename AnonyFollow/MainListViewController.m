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
#import "MessageBarButtonItem.h"
#import "SNStatusBarView.h"
#import "SNReachablityChecker.h"

#import <Accounts/Accounts.h>

@implementation MainListViewController

#pragma mark - Instance method

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
					self.twitterAccountButton.label.text = twitterAccount.username;
					self.advertizer = [[CBAdvertizer alloc] initWithDelegate:self userName:twitterAccount.username];
					self.scanner = [[CBScanner alloc] initWithDelegate:self serviceUUID:nil];
				});
			}
			else{
				NSLog(@"No Twitter Account");
				self.segmentedControl.selectedSegmentIndex = 0;
			}
		}else{
			// if user does not permit access to twitter account
			NSLog(@"accountStore accesss denied");
			self.segmentedControl.selectedSegmentIndex = 0;
		}
		self.segmentedControl.userInteractionEnabled = YES;
	}];
}

- (IBAction)select:(id)sender {
	UISegmentedControl *control = self.segmentedControl;
	if (control.selectedSegmentIndex == 0) {
		[self.scanner stopScan];
		self.scanner = nil;
		[self.advertizer stopAdvertize];
		self.advertizer = nil;
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
	[self.accounts removeAllObjects];
	[self.tableView reloadData];
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:SNReachablityDidChangeNotification object:nil];
	
	self.accounts = [NSMutableArray array];

#if 0
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
#endif
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - CBAdvertizerDelegate

- (void)advertizerDidChangeStatus:(CBAdvertizer*)advertizer {
}

#pragma mark - CBScannerDelegate

- (void)scanner:(CBScanner*)scanner didDiscoverUser:(NSDictionary*)userInfo {
	NSString *username = [userInfo objectForKey:kCBScannerInfoUserNameKey];
	TwitterAccountInfo *info = [[TwitterAccountInfo alloc] init];
	info.screenName = username;
	[self.accounts addObject:info];
	[self.tableView reloadData];
	AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
	[del.barView pushTemporaryMessage:[NSString stringWithFormat:@"Found %@", username]];
}

- (void)scannerDidChangeStatus:(CBScanner*)scanner {
	if ([self.scanner isAvailable]) {
		AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
		[del.barView setColor:[UIColor greenColor]];
		[del.barView setMessage:NSLocalizedString(@"Broadcasting...", nil)];
	}
	else {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
		[self.scanner stopScan];
		[self.advertizer stopAdvertize];
	}
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

@end
