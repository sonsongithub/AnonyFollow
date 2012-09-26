//
//  MainListViewController.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import "MainListViewController.h"

NSString *kNotificationDidFollowUser = @"kNotificationDidFollowUser";
NSString *kNotificationUserInfoUserNameKey = @"kNotificationUserInfoUserNameKey";

#define DEFAULT_MAIN_VIEW_CELL_HEIGHT		58

@interface MainListViewController ()
@end

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

typedef void (^AfterBlocks)(NSString *userName, ACAccountStore *accountStore);

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
	[self performBlockAfterRequestingTwitterAccout:^(NSString *twitterUserName, ACAccountStore *accountStore) {		
		[self.twitterAccountButton setTwitterAccountUserName:twitterUserName];
		self.advertizer = [[CBAdvertizer alloc] initWithDelegate:self userName:twitterUserName serviceUUID:@"1802"];
		self.scanner = [[CBScanner alloc] initWithDelegate:self serviceUUID:@"1802"];
		self.lockScreenView.hidden = YES;
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
	
	[self updateTrashButton];
}

- (void)followOnTwitter:(NSString*)screenName {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
			ACAccount *account = [accountStore twitterCurrentAccount];
			
			if (account == nil) {
				// can't access twitter account
				dispatch_async(dispatch_get_main_queue(), ^(void){
					[self stopLoadingAnimationWithScreenName:screenName];
				});
				return;
			}
			
			NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
			[tempDict setValue:screenName forKey:@"screen_name"];
			
			SLRequest *postRequest;
			[tempDict setValue:@"true" forKey:@"follow"];
			postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1/friendships/create.json"] parameters:tempDict];
                
			[postRequest setAccount:account];
			[postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
				if ([urlResponse statusCode] == 403 ||  [urlResponse statusCode] == 200) {
					dispatch_async(dispatch_get_main_queue(), ^(void){
						[self removeUserNameFromListWithUserName:screenName];
						[self stopLoadingAnimationWithScreenName:screenName];
					});
				}
				else {
					// Error?
					DNSLog(@"%@", [error localizedDescription]);
					DNSLog(@"Error?");
					dispatch_async(dispatch_get_main_queue(), ^(void){
						
						[self stopLoadingAnimationWithScreenName:screenName];
						UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
																			message:[error localizedDescription]
																		   delegate:nil
																  cancelButtonTitle:nil
																  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
						[alertView show];
					});
				}
			}];
        }
		else {
			// unknown error
			dispatch_async(dispatch_get_main_queue(), ^(void){
				[self stopLoadingAnimationWithScreenName:screenName];
			});
		}
    }];
}

- (void)notifyRecevingOnBackgroundWithUserName:(NSString*)username {
	UILocalNotification *localNotif = [[UILocalNotification alloc] init];
	NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%@ is boardcasting", nil), username];
	localNotif.alertBody = message;
	localNotif.alertAction = NSLocalizedString(@"Exhange", nil);
	localNotif.soundName = UILocalNotificationDefaultSoundName;
	[[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
}

- (void)showAlertMessage:(NSString*)message {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil)
														message:message
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	[alertView show];
}

- (void)updateTrashButton {
	self.trashButton.enabled = ([self.accounts count] > 0);
	[self.navigationController setToolbarItems:self.navigationController.toolbarItems];
}

- (void)stopLoadingAnimationWithScreenName:(NSString*)screenName {
	NSArray *visibleCells = [self.tableView visibleCells];
	for (AccountCell *cell in visibleCells) {
		if ([cell.accountInfo.screenName isEqualToString:screenName]) {
			[cell stopLoading];
		}
	}
}

#pragma mark - NSNotification

- (void)didFollowUser:(NSNotification*)notification {
	NSString *userName = [[notification userInfo] objectForKey:kNotificationUserInfoUserNameKey];
	[self removeUserNameFromListWithUserName:userName];
}

- (void)willEnterForeground:(NSNotification*)notification {
	DNSLogMethod
	DNSLog(@"%@", notification);
	self.lockScreenView.hidden = YES;
	//[self.scanner stopScan];
	//self.scanner = nil;
	//self.segmentedControl.selectedSegmentIndex = 0;
	//[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)didEnterBackground:(NSNotification*)notification {
	DNSLogMethod
	
	//[self.advertizer stopAdvertize];
	//self.advertizer = nil;
	//[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kAnonyFollowBackgroundScanEnabled]) {
	}
	else {
		[self.scanner stopScan];
		self.scanner = nil;
	}
	[[DownloadQueue sharedInstance] clearQueue];
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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self.accounts removeAllObjects];
		[self.tableView reloadData];
		
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[self updateTrashButton];
		});
	}
}

#pragma mark - UIViewController life cycle

- (void)updateAccountButtonMessage {
	[self performBlockAfterRequestingTwitterAccout:^(NSString *twitterUserName, ACAccountStore *accountStore) {
		[self.twitterAccountButton setTwitterAccountUserName:twitterUserName];
	}];
}

- (void)performBlockAfterRequestingTwitterAccout:(AfterBlocks)blocks {
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
					blocks(twitterUserName, accountStore);
				});
			}
			else {
				DNSLog(@"No Twitter Account");
				dispatch_async(dispatch_get_main_queue(), ^(void) {
					self.lockScreenView.hidden = NO;
					[self showAlertMessage:NSLocalizedString(@"Plesase setup or authorize twitter account via Setting.app.", nil)];
					[self.twitterAccountButton setTwitterAccountUserName:NSLocalizedString(@"No account", nil)];
					self.segmentedControl.selectedSegmentIndex = 0;
				});
			}
		}
		else {
			DNSLog(@"accountStore accesss denied");
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				self.lockScreenView.hidden = NO;
				[self showAlertMessage:NSLocalizedString(@"Plesase setup or authorize twitter account via Setting.app.", nil)];
				[self.twitterAccountButton setTwitterAccountUserName:NSLocalizedString(@"Not authorized", nil)];
				self.segmentedControl.selectedSegmentIndex = 0;
			});
		}
	}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// setup notification
	// background and foreground
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	
	// network status notification
	[[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:SNReachablityDidChangeNotification object:nil];
	
	// notification of following
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFollowUser:) name:kNotificationDidFollowUser object:nil];
	
	// set up buffer
	self.accounts = [NSMutableArray array];
	self.accountsCollectedOnBackground = [NSMutableArray array];
	self.twitterAccountButton.delegate = self;
	
	// setup status bar
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
	[appdelegate setupOriginalStatusBar];
	
	self.lockScreenView.hidden = YES;
	
	self.trashButton.enabled = ([self.accounts count] > 0);
	
#if 0
	// for debugging, dummy data
	for (int i = 0; i < 40; i++) {
		TwitterAccountInfo *info = [[TwitterAccountInfo alloc] init];
		info.screenName = @"sonson_twit";
		[self.accounts addObject:info];
	}
	[self.tableView reloadData];
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

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self loadImagesForOnscreenRows];
    [self resetBadge];

	[UIView animateWithDuration:0.4 animations:^(void){
		UIScreen *screen = [UIScreen mainScreen];
		CGSize size = screen.bounds.size;
		size.height -= STATUS_BAR_HEIGHT;
		CGRect frame = CGRectMake(0, STATUS_BAR_HEIGHT, size.width, size.height);
		self.navigationController.view.frame = frame;
	}];
	
	NSIndexPath *path = [self.tableView indexPathForSelectedRow];
	if (path)
		[self.tableView deselectRowAtIndexPath:path animated:YES];

	[self updateAccountButtonMessage];
}

#pragma mark - MessageBarButtonItemDelegate

- (void)didTouchMessageBarButtonItem:(MessageBarButtonItem*)item {
	DNSLogMethod
	
	[self performBlockAfterRequestingTwitterAccout:^(NSString *twitterUserName, ACAccountStore *accountStore) {
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
	}];
}

#pragma mark - IBAction

- (IBAction)follow:(id)sender {
	DNSLogMethod
	UIButton *button = sender;
	TwitterAccountInfo *info = [self.accounts objectAtIndex:button.tag];
	
	// try to start loading
	NSArray *visibleCells = [self.tableView visibleCells];
	for (AccountCell *cell in visibleCells) {
		if ([cell.accountInfo.screenName isEqualToString:info.screenName]) {
			[cell startLoading];
		}
	}
	
	// try to follow him
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
}

- (IBAction)trash:(id)sender {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Find List", nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
										 destructiveButtonTitle:NSLocalizedString(@"Delete", nil)
											  otherButtonTitles:nil];
	[sheet showFromToolbar:self.navigationController.toolbar];
}

#pragma mark - CBAdvertizerDelegate

- (void)advertizerDidChangeStatus:(CBAdvertizer*)advertizer {
}

- (void)debugAddUserNameOnForeground:(NSString*)userName {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kAnonyFollowDebugShowRedundantUsers]) {
		for (TwitterAccountInfo *existing in self.accounts) {
			if ([existing.screenName isEqualToString:userName])
				return;
		}
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kAnonyFollowDebugShowFollowingUsers]) {
		TwitterAccountInfo *info = [[TwitterAccountInfo alloc] init];
		info.screenName = userName;
		[self.accounts addObject:info];
		[self updateTrashButton];
		[self.tableView reloadData];
		AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
		[del.barView pushTemporaryMessage:[NSString stringWithFormat:NSLocalizedString(@"Found %@", nil), userName]];
	}
	else {
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
							dispatch_async(dispatch_get_main_queue(), ^(void){
								AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
								[del.barView pushTemporaryMessage:[NSString stringWithFormat:NSLocalizedString(@"%@ is already followed", nil), userName]];
							});
						}
						else if ([result isEqualToString:@"false"]) {
							dispatch_async(dispatch_get_main_queue(), ^(void){
								
								for (TwitterAccountInfo *existing in self.accounts) {
									if ([existing.screenName isEqualToString:userName])
										return;
								}
								
								TwitterAccountInfo *info = [[TwitterAccountInfo alloc] init];
								info.screenName = userName;
								[self.accounts addObject:info];
								[self updateTrashButton];
								[self.tableView reloadData];
								AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
								[del.barView pushTemporaryMessage:[NSString stringWithFormat:NSLocalizedString(@"Found %@", nil), userName]];
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
						dispatch_async(dispatch_get_main_queue(), ^(void){
							AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
							[del.barView pushTemporaryMessage:[NSString stringWithFormat:NSLocalizedString(@"%@ is already followed", nil), userName]];
						});
					}
					else if ([result isEqualToString:@"false"]) {
						dispatch_async(dispatch_get_main_queue(), ^(void){
							
							for (TwitterAccountInfo *existing in self.accounts) {
								if ([existing.screenName isEqualToString:userName])
									return;
							}
							
							TwitterAccountInfo *info = [[TwitterAccountInfo alloc] init];
							info.screenName = userName;
							[self.accounts addObject:info];
							[self updateTrashButton];
							[self.tableView reloadData];
							AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
							[del.barView pushTemporaryMessage:[NSString stringWithFormat:NSLocalizedString(@"Found %@", nil), userName]];
						});
					}
					else {
						// exception
					}
				}
				else {
					// can't access?
					dispatch_async(dispatch_get_main_queue(), ^(void){
						
						for (TwitterAccountInfo *existing in self.accounts) {
							if ([existing.screenName isEqualToString:userName])
								return;
						}
						
						TwitterAccountInfo *info = [[TwitterAccountInfo alloc] init];
						info.screenName = userName;
						[self.accounts addObject:info];
						[self updateTrashButton];
						[self.tableView reloadData];
						AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
						[del.barView pushTemporaryMessage:[NSString stringWithFormat:NSLocalizedString(@"Found %@", nil), userName]];
					});
				}
			}];
		}
	}];
}

#pragma mark - CBScannerDelegate

- (void)scanner:(CBScanner*)scanner didDiscoverUser:(NSDictionary*)userInfo {
	NSString *username = [userInfo objectForKey:kCBScannerInfoUserNameKey];
	
	DNSLog(@"%d", [NSThread isMainThread]);
	
	if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
		// post local notification
		[self notifyRecevingOnBackgroundWithUserName:username];
	}
	else {
#ifdef _DEBUG
		[self debugAddUserNameOnForeground:username];
#else
		[self addUserNameOnForeground:username];
#endif
	}
}

- (void)scannerDidChangeStatus:(CBScanner*)scanner {
	DNSLogMethod
	if ([self.scanner isAvailable]) {
		self.lockScreenView.hidden = YES;
		AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
		[del.barView setColor:[UIColor greenColor]];
		[del.barView setMessage:NSLocalizedString(@"Broadcasting...", nil)];
	}
	else {
		self.lockScreenView.hidden = NO;
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
		[self.scanner stopScan];
		self.scanner.delegate = nil;
		self.scanner = nil;
		[self.advertizer stopAdvertize];
		self.advertizer.delegate = nil;
		self.advertizer = nil;
	}
}

#pragma mark - Table view data source

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return DEFAULT_MAIN_VIEW_CELL_HEIGHT;
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
		[self updateTrashButton];
    }
}

@end
