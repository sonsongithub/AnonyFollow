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

#import "AccountSelectViewController.h"

#import <Accounts/Accounts.h>

#import "ACAccountStore+AnonyFollow.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

@implementation MainListViewController

#pragma mark - Instance method

- (void)incrementBadge {
    UIApplication* app = [UIApplication sharedApplication];
    [UIApplication sharedApplication].applicationIconBadgeNumber = app.applicationIconBadgeNumber+1;
}

- (void)resetBadge {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)enableBroadcasting {
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	self.segmentedControl.userInteractionEnabled = NO;
	
	[accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
		if (error) {
			NSLog(@"%@", [error localizedDescription]);
		}
		if (granted) {
			NSString *twitterUserName = [accountStore twitterAvailableUserName];
			if ([twitterUserName length]) {
				dispatch_async(dispatch_get_main_queue(), ^(void) {
					[self.twitterAccountButton setTwitterAccountUserName:twitterUserName];
					self.advertizer = [[CBAdvertizer alloc] initWithDelegate:self userName:twitterUserName];
					self.scanner = [[CBScanner alloc] initWithDelegate:self serviceUUID:nil];
				});
			}
			else {
				DNSLog(@"No Twitter Account");
				dispatch_async(dispatch_get_main_queue(), ^(void) {
					[self.twitterAccountButton setTwitterAccountUserName:NSLocalizedString(@"No account", nil)];
					self.segmentedControl.selectedSegmentIndex = 0;
				});
			}
		}
		else {
			DNSLog(@"accountStore accesss denied");
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				[self.twitterAccountButton setTwitterAccountUserName:NSLocalizedString(@"Not authorized", nil)];
				self.segmentedControl.selectedSegmentIndex = 0;
			});
		}
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			self.segmentedControl.userInteractionEnabled = YES;
		});
	}];
}

- (void)removeUserNameFromListWithUserName:(NSString*)userName {
	//
	NSMutableArray *indexPathToDeDeleted = [NSMutableArray array];
	
	DNSLog(@"Maybe, OK");
	for (int i = [self.accounts count] - 1; i >= 0 ; i--) {
		if (i < [self.accounts count]) {
			TwitterAccountInfo *info = [self.accounts objectAtIndex:i];
			if ([info.screenName isEqualToString:userName]) {
				[indexPathToDeDeleted addObject:[NSIndexPath indexPathForRow:i inSection:0]];
				[self.accounts removeObjectAtIndex:i];
				
			}
		}
	}
	
	if ([indexPathToDeDeleted count]) {
		[self.tableView deleteRowsAtIndexPaths:indexPathToDeDeleted withRowAnimation:UITableViewRowAnimationLeft];
		for (AccountCell *cell in [self.tableView visibleCells]) {
			NSIndexPath *path = [self.tableView indexPathForCell:cell];
			cell.followButton.tag = path.row;
		}
	}
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
						[self removeUserNameFromListWithUserName:userName];
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

- (void)checkFollowing:(NSString*)screenNameA him:(NSString*)screenNameB {
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
			ACAccount *account = [accountStore twitterCurrentAccount];
			
			if (account == nil)
				return;
			
			NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
			
			SLRequest *postRequest;
			[tempDict setValue:screenNameA forKey:@"screen_name_a"];
			[tempDict setValue:screenNameB forKey:@"screen_name_b"];
			postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1/friendships/exists.json"] parameters:tempDict];
			
			[postRequest setAccount:account];
			[postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
				if (error == nil) {
					NSError *jsonError = nil;
					NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
					DNSLog(@"%@", result);
				}
			}];
        }
    }];
}

- (void)didFollowUser:(NSNotification*)notification {
	NSString *userName = [[notification userInfo] objectForKey:@"userName"];
	[self removeUserNameFromListWithUserName:userName];
}

- (void)willEnterForeground:(NSNotification*)notification {
	DNSLogMethod
	for (NSString *userName in self.accountsCollectedOnBackground) {
		DNSLog(@"%@", userName);
	}
	[self.accountsCollectedOnBackground removeAllObjects];
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

#pragma mark - UIViewController life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:SNReachablityDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFollowUser:) name:@"didFollowUser" object:nil];
	self.accounts = [NSMutableArray array];
	self.accountsCollectedOnBackground = [NSMutableArray array];
	self.twitterAccountButton.delegate = self;

	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	[accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
		if (error) {
			NSLog(@"%@", [error localizedDescription]);
		}
		if (granted) {
			NSString *twitterUserName = [accountStore twitterAvailableUserName];
			if ([twitterUserName length]) {
				dispatch_async(dispatch_get_main_queue(), ^(void) {
					[self.twitterAccountButton setTwitterAccountUserName:twitterUserName];
				});
			}
			else {
				DNSLog(@"No Twitter Account");
				dispatch_async(dispatch_get_main_queue(), ^(void) {
					[self.twitterAccountButton setTwitterAccountUserName:NSLocalizedString(@"No account", nil)];
				});
			}
		}
		else {
			DNSLog(@"accountStore accesss denied");
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				[self.twitterAccountButton setTwitterAccountUserName:NSLocalizedString(@"Not authorized", nil)];
			});
		}
	}];
	
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
    [self resetBadge];
	
	[UIView animateWithDuration:0.4 animations:^(void){
		self.navigationController.view.frame = CGRectMake(0, 20, 320, 460);
	}];
	
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	[accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
		if (error) {
			NSLog(@"%@", [error localizedDescription]);
		}
		if (granted) {
			NSString *twitterUserName = [accountStore twitterAvailableUserName];
			if ([twitterUserName length]) {
				dispatch_async(dispatch_get_main_queue(), ^(void) {
					[self.twitterAccountButton setTwitterAccountUserName:twitterUserName];
				});
			}
			else {
				DNSLog(@"No Twitter Account");
				dispatch_async(dispatch_get_main_queue(), ^(void) {
					[self.twitterAccountButton setTwitterAccountUserName:NSLocalizedString(@"No account", nil)];
				});
			}
		}
		else {
			DNSLog(@"accountStore accesss denied");
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				[self.twitterAccountButton setTwitterAccountUserName:NSLocalizedString(@"Not authorized", nil)];
			});
		}
	}];
}

#pragma mark - MessageBarButtonItemDelegate

- (void)didTouchMessageBarButtonItem:(MessageBarButtonItem*)item {
	DNSLogMethod
	
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	[accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
		if (error) {
			NSLog(@"%@", [error localizedDescription]);
		}
		if (granted) {
			NSString *twitterUserName = [accountStore twitterAvailableUserName];
			if ([twitterUserName length]) {
				dispatch_async(dispatch_get_main_queue(), ^(void) {
					[self.scanner stopScan];
					self.scanner = nil;
					[self.advertizer stopAdvertize];
					self.advertizer = nil;
					self.segmentedControl.selectedSegmentIndex = 0;
					[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
					
					UINavigationController *nv = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectAccountNavigationController"];
					AccountSelectViewController *vc = (AccountSelectViewController*)nv.topViewController;
					
					NSMutableArray *nameList = [NSMutableArray array];
					
					NSArray *accountsArray = [accountStore accountsWithAccountType:[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];
					for (ACAccount *account in accountsArray) {
						[nameList addObject:account.username];
					}
					vc.userNameList = nameList;
					
					[self presentViewController:nv animated:YES completion:^(void){}];
				});
			}
			else {
				DNSLog(@"No Twitter Account");
				dispatch_async(dispatch_get_main_queue(), ^(void) {
					[self.twitterAccountButton setTwitterAccountUserName:NSLocalizedString(@"No account", nil)];
				});
			}
		}
		else {
			DNSLog(@"accountStore accesss denied");
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				[self.twitterAccountButton setTwitterAccountUserName:NSLocalizedString(@"Not authorized", nil)];
			});
		}
	}];
	
}

#pragma mark - IBAction

- (IBAction)follow:(id)sender {
	DNSLogMethod
	UIButton *button = sender;
	TwitterAccountInfo *info = [self.accounts objectAtIndex:button.tag];
	[self followOnTwitter:info.screenName];
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

#pragma mark - CBAdvertizerDelegate

- (void)advertizerDidChangeStatus:(CBAdvertizer*)advertizer {
}

- (void)addUserNameOnForeground:(NSString*)userName {
	
	for (TwitterAccountInfo *existing in self.accounts) {
		if ([existing.screenName isEqualToString:userName])
			return;
	}
	
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
			ACAccount *account = [accountStore twitterCurrentAccount];
			
			if (account == nil)
				return;
			
			NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
			
			SLRequest *postRequest;
			[tempDict setValue:account.username forKey:@"screen_name_a"];
			[tempDict setValue:userName forKey:@"screen_name_b"];
			postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1/friendships/exists.json"] parameters:tempDict];
			
			[postRequest setAccount:account];
			[postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
				if (error == nil) {
					NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
					NSLog(@"%@", result);
					if ([result isEqualToString:@"true"]) {
					}
					else if ([result isEqualToString:@"false"]) {
						dispatch_async(dispatch_get_main_queue(), ^(void){
							TwitterAccountInfo *info = [[TwitterAccountInfo alloc] init];
							info.screenName = userName;
							[self.accounts addObject:info];
							[self.tableView reloadData];
							AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
							[del.barView pushTemporaryMessage:[NSString stringWithFormat:@"Found %@", userName]];
						});
					}
					else {
						// error
					}
				}
			}];
        }
    }];
}

- (void)addUserNameOnBackground:(NSString*)userName {
	if (![self.accountsCollectedOnBackground indexOfObject:userName])
		[self.accountsCollectedOnBackground addObject:userName];
}

#pragma mark - CBScannerDelegate

- (void)scanner:(CBScanner*)scanner didDiscoverUser:(NSDictionary*)userInfo {
	NSString *username = [userInfo objectForKey:kCBScannerInfoUserNameKey];
	
	if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
		[self addUserNameOnBackground:username];
	}
	else {
		[self addUserNameOnForeground:username];
	}
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
