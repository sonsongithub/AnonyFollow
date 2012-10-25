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

typedef void (^AfterBlocks)(NSString *screenName, ACAccountStore *accountStore);

@implementation MainListViewController

#pragma mark - Instance method

#pragma mark - Serialize

- (void)serializeAccounts {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *plistPath = [NSString stringWithFormat:@"%@/accounts.plist", documentsDirectory];
	NSData *data = [TwitterAccountInfo dataWithArrayOfTwitterAccountInfo:self.accounts];
	[data writeToFile:plistPath atomically:NO];
}

- (void)deserializeAccounts {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *plistPath = [NSString stringWithFormat:@"%@/accounts.plist", documentsDirectory];
	
	self.accounts = [NSMutableArray array];
	NSData *data  = [NSData dataWithContentsOfFile:plistPath];
	[self.accounts addObjectsFromArray:[TwitterAccountInfo arrayOfTwitterAccountInfoWithSerializedData:data]];
	
	// remove saved file
	[[NSFileManager defaultManager] removeItemAtPath:plistPath error:nil];
}

#pragma mark - Applicatoin badge control

- (void)incrementBadge {
    UIApplication* app = [UIApplication sharedApplication];
    [UIApplication sharedApplication].applicationIconBadgeNumber = app.applicationIconBadgeNumber+1;
}

- (void)resetBadge {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

#pragma mark - Bluetooth controller management

- (void)enableBroadcasting {
	[self performBlockAfterRequestingTwitterAccout:^(NSString *twitterUserName, ACAccountStore *accountStore) {		
		[self.twitterAccountButton setTwitterAccountUserName:twitterUserName];
		self.advertizer = [[CBAdvertizer alloc] initWithDelegate:self userName:twitterUserName serviceUUID:BLE_SERVICE_UUID];
		self.scanner = [[CBScanner alloc] initWithDelegate:self serviceUUID:BLE_SERVICE_UUID];
		self.lockScreenView.hidden = YES;
	}];
}

- (void)stopBoardcasting {
	// stop and release advertiser
	[self.advertizer stopAdvertize];
	self.advertizer.delegate = nil;
	self.advertizer = nil;
	
	// stop and release scanner
	[self.scanner stopScan];
	self.scanner.delegate = nil;
	self.scanner = nil;
	
	// recover UI
	self.segmentedControl.selectedSegmentIndex = 0;
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - Twitter controller

- (BOOL)doesMainListAlreadyInclude:(NSString*)screenName {
	for (TwitterAccountInfo *existing in self.accounts) {
		if ([existing.screenName isEqualToString:screenName])
			return YES;
	}
	return NO;
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
					[self showAlertTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Plesase setup or authorize twitter account via Setting.app.", nil)];
					[self.twitterAccountButton setTwitterAccountUserName:NSLocalizedString(@"No account", nil)];
					self.segmentedControl.selectedSegmentIndex = 0;
				});
			}
		}
		else {
			DNSLog(@"accountStore accesss denied");
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				self.lockScreenView.hidden = NO;
				[self showAlertTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Plesase setup or authorize twitter account via Setting.app.", nil)];
				[self.twitterAccountButton setTwitterAccountUserName:NSLocalizedString(@"Not authorized", nil)];
				self.segmentedControl.selectedSegmentIndex = 0;
			});
		}
	}];
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
						[self showAlertTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription]];
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

#pragma mark - Post local notification on Background

- (void)notifyRecevingOnBackgroundWithMessage:(NSString*)message {
	UILocalNotification *localNotif = [[UILocalNotification alloc] init];
	localNotif.alertBody = message;
	localNotif.alertAction = NSLocalizedString(@"Open", nil);
	localNotif.soundName = UILocalNotificationDefaultSoundName;
	[[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
}

#pragma mark - Simple messaging with UIAlertView

- (void)showAlertTitle:(NSString*)title message:(NSString*)message {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
														message:message
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	[alertView show];
}

#pragma mark - UI management

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

- (void)removeUserNameFromListWithUserName:(NSString*)userName {
	// remove twitter account from list
	// and create list of cells to be removed
	NSMutableArray *indexPathToDeDeleted = [NSMutableArray array];
	for (int i = [self.accounts count] - 1; i >= 0 ; i--) {
		if (i < [self.accounts count]) {
			TwitterAccountInfo *info = [self.accounts objectAtIndex:i];
			if ([info.screenName isEqualToString:userName]) {
				[indexPathToDeDeleted addObject:[NSIndexPath indexPathForRow:i inSection:0]];
				[self.accounts removeObjectAtIndex:i];
				
			}
		}
	}
	
	// remove cells
	if ([indexPathToDeDeleted count]) {
		[self.tableView deleteRowsAtIndexPaths:indexPathToDeDeleted withRowAnimation:UITableViewRowAnimationLeft];
		for (AccountCell *cell in [self.tableView visibleCells]) {
			NSIndexPath *path = [self.tableView indexPathForCell:cell];
			cell.followButton.tag = path.row;
		}
	}
	
	// update trash button
	[self updateTrashButton];
}

- (void)updateAccountButtonMessage {
	[self performBlockAfterRequestingTwitterAccout:^(NSString *twitterUserName, ACAccountStore *accountStore) {
		[self.twitterAccountButton setTwitterAccountUserName:twitterUserName];
	}];
}

#pragma mark - NSNotification

- (void)didFollowUser:(NSNotification*)notification {
	NSString *userName = [[notification userInfo] objectForKey:kNotificationUserInfoUserNameKey];
	[self removeUserNameFromListWithUserName:userName];
}

- (void)willEnterForeground:(NSNotification*)notification {
	DNSLogMethod
	self.lockScreenView.hidden = YES;
	
	// Reset application badge whicn means how many times you exchanged accounts.
	[self resetBadge];
	
	[self.tableView reloadData];
}

- (void)didEnterBackground:(NSNotification*)notification {
	DNSLogMethod
		
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kAnonyFollowBackgroundScanEnabled]) {
		// background mode
	}
	else {
		// stop all controllers when no background mode
		[self stopBoardcasting];
	}
	
	// clear download queue
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

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self resetBadge];
	
	// forcely, bring lockview to front
	[self.view bringSubviewToFront:self.lockScreenView];
	
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
	self.history = [NSMutableArray array];
	self.twitterAccountButton.delegate = self;
	
	// load seralized data when application aborted in background task.
	[self deserializeAccounts];
	
	// setup status bar
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
	[appdelegate setupOriginalStatusBar];
	
	// Manage UI
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
	if ([segue.identifier isEqualToString:@"ToSettingViewController"]) {
		[self stopBoardcasting];
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

	[UIView animateWithDuration:0.4
					 animations:^(void) {
						 UIScreen *screen = [UIScreen mainScreen];
						 CGSize size = screen.bounds.size;
						 size.height -= STATUS_BAR_HEIGHT;
						 CGRect frame = CGRectMake(0, STATUS_BAR_HEIGHT, size.width, size.height);
						 self.navigationController.view.frame = frame;
					 }
					 completion:^(BOOL completion) {
						 if ([[NSUserDefaults standardUserDefaults] boolForKey:kAnonyFollowShownHelpVer100]) {
						 }
						 else {
							 UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
							 [self presentViewController:vc animated:YES completion:^(void){}];
							 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAnonyFollowShownHelpVer100];
							 [[NSUserDefaults standardUserDefaults] synchronize];
						 }
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
		[self stopBoardcasting];

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
	
	// get selected account information
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
		[self stopBoardcasting];
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

- (void)addScreenName:(NSString*)screenName {
	if ([self doesMainListAlreadyInclude:screenName])
		return;
	
	TwitterAccountInfo *info = [[TwitterAccountInfo alloc] init];
	info.screenName = screenName;
	[self.accounts addObject:info];
	[self updateTrashButton];
	[self.tableView reloadData];
	
	
	if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
		AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
		[del.barView pushTemporaryMessage:[NSString stringWithFormat:NSLocalizedString(@"Found %@", nil), screenName]];
	}
	else if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
		// post local notification
		[self notifyRecevingOnBackgroundWithMessage:[NSString stringWithFormat:NSLocalizedString(@"Found %@", nil), screenName]];
		// increment number of badge
		[self incrementBadge];
		[self serializeAccounts];
	}
}

- (void)checkFollowingAndAddListWithScreenName:(NSString*)screenName account:(ACAccount*)account {
	NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
	
	SLRequest *postRequest;
	[tempDict setValue:account.username forKey:@"screen_name_a"];
	[tempDict setValue:screenName forKey:@"screen_name_b"];
	postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1/friendships/exists.json"] parameters:tempDict];
	
	[postRequest setAccount:account];
	[postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		if (error == nil) {
			NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
			NSLog(@"%@", result);
			if ([result isEqualToString:@"true"]) {
				dispatch_async(dispatch_get_main_queue(), ^(void){
					if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
						AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
						[del.barView pushTemporaryMessage:[NSString stringWithFormat:NSLocalizedString(@"%@ is already followed", nil), screenName]];
					}
					else if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
						// post local notification
						[self notifyRecevingOnBackgroundWithMessage:[NSString stringWithFormat:NSLocalizedString(@"%@ is already followed", nil), screenName]];
					}
				});
				return;
			}
		}
		// when error happens or the acccount is not followed
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[self addScreenName:screenName];
		});
	}];
}

- (void)debugAddScreenNameOnForeground:(NSString*)screenName {
	// for debugging
	
	// avoid redundancy?
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kAnonyFollowDebugShowRedundantUsers]) {
		if ([self doesMainListAlreadyInclude:screenName])
			return;
	}
	
	// avoid already followed users?
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kAnonyFollowDebugShowFollowingUsers]) {
		[self addScreenName:screenName];
	}
	else {
		// normal
		ACAccountStore *accountStore = [[ACAccountStore alloc] init];
		ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
		[accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
			if(granted) {
				ACAccount *account = [accountStore twitterCurrentAccount];
				if (account) {
					[self checkFollowingAndAddListWithScreenName:screenName account:account];
					return;
				}
			}
			// when error happens, forcely added screen name into the main list
			dispatch_async(dispatch_get_main_queue(), ^(void){
				[self addScreenName:screenName];
			});
		}];
	}
}

- (void)addScreenNameOnForeground:(NSString*)screenName {
	// check already received?
	if ([self doesMainListAlreadyInclude:screenName])
		return;
	
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	[accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
		if(granted) {
			ACAccount *account = [accountStore twitterCurrentAccount];
			if (account) {
				[self checkFollowingAndAddListWithScreenName:screenName account:account];
				return;
			}
		}
		// when error happens, forcely added screen name into the main list
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[self addScreenName:screenName];
		});
	}];
}

#pragma mark - CBScannerDelegate

- (void)scanner:(CBScanner*)scanner didDiscoverUser:(NSDictionary*)userInfo {
	NSString *screenName = [userInfo objectForKey:kCBScannerInfoUserNameKey];
#ifdef _DEBUG
	[self debugAddScreenNameOnForeground:screenName];
#else
	[self addScreenNameOnForeground:screenName];
#endif
}

- (void)scannerDidChangeStatus:(CBScanner*)scanner {
	DNSLogMethod
	if ([self.scanner isAvailable]) {
		// start scanning and advertising via Bluetooth
		if ([[NSUserDefaults standardUserDefaults] boolForKey:kAnonyFollowBackgroundScanEnabled]) {
			// background mode
			self.lockScreenView.hidden = YES;
			AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
			[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
			[del.barView setColor:[UIColor redColor]];
			[del.barView setMessage:NSLocalizedString(@"Background broadcasting...", nil)];
		}
		else {
			// normal mode
			self.lockScreenView.hidden = YES;
			AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
			[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
			[del.barView setColor:[UIColor greenColor]];
			[del.barView setMessage:NSLocalizedString(@"Broadcasting...", nil)];
		}
	}
	else {
		// stop scanning and advertising via Bluetooth
		self.lockScreenView.hidden = NO;
		[self stopBoardcasting];
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
