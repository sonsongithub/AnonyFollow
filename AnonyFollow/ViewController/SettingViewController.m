//
//  SettingViewController.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import "SettingViewController.h"
#import "NSBundle+AnonyFollow.h"
#import "UIViewController+AnonyFollow.h"
#import "NSUserDefaults+AnonyFollow.h"
#import "UIDevice+AnonyFollow.h"
#import "UIApplication+AnonyFollow.h"

@interface SettingViewController ()
@end

@implementation SettingViewController

#pragma mark - Instance method

- (void)sendFeedbackMail {
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		[picker setSubject:NSLocalizedString(@"[AnonyFollow contact] ", nil)];
		[picker setToRecipients:[NSArray arrayWithObject:NSLocalizedString(@"SupportMailAddress", nil)]];
		
		NSString *body = [NSString stringWithFormat:NSLocalizedString(@"\n\nYour system's information ----------\nAnonyFollow %@\niOS %@\n Device %@", nil), [[UIApplication sharedApplication] versionString], [UIDevice currentDevice].systemVersion, [[UIDevice currentDevice] _platformString]];
		
		[picker setMessageBody:body isHTML:NO];
		
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
			picker.modalPresentationStyle = UIModalPresentationFormSheet;
		[self presentViewController:picker animated:YES completion:^(void){}];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Mail error", nil)
														message:NSLocalizedString(@"App needs a mail account in order to send your report.", nil)
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
											  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
		[alert show];
	}
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	BOOL flag = NO;
	if (buttonIndex == 0)
		flag = NO;
	if (buttonIndex == 1)
		flag = YES;
	[[NSUserDefaults standardUserDefaults] setBool:flag forKey:kAnonyFollowBackgroundScanEnabled];
	[[NSUserDefaults standardUserDefaults] synchronize];
	self.backgroundSwitch.on = flag;
}

#pragma mark - IBOutlet

- (IBAction)didChangeBackgroundSwitch:(id)sender {
	if (sender == self.backgroundSwitch) {
		[[NSUserDefaults standardUserDefaults] setBool:self.backgroundSwitch.on forKey:kAnonyFollowBackgroundScanEnabled];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		
		if (self.backgroundSwitch.on) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil)
																message:NSLocalizedString(@"Confirm anonymous communication", nil)
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"Disable", nil)
													  otherButtonTitles:NSLocalizedString(@"Enable", nil), nil];
			[alertView show];
		}
	}
}

- (IBAction)didChangeShowFollowingSwitch:(id)sender {
	if (sender == self.showFollowingSwitch) {
		[[NSUserDefaults standardUserDefaults] setBool:self.showFollowingSwitch.on forKey:kAnonyFollowDebugShowFollowingUsers];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (IBAction)didChangeShowRedundantSwitch:(id)sender {
	if (sender == self.showRedundantSwitch) {
		[[NSUserDefaults standardUserDefaults] setBool:self.showRedundantSwitch.on forKey:kAnonyFollowDebugShowRedundantUsers];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

#pragma mark - ViewController lifecycle

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([UIApplication sharedApplication].statusBarHidden) {
		[UIView animateWithDuration:0.4 animations:^(void){
			UIScreen *screen = [UIScreen mainScreen];
			CGSize size = screen.bounds.size;
			size.height -= STATUS_BAR_HEIGHT;
			CGRect frame = CGRectMake(0, STATUS_BAR_HEIGHT, size.width, size.height);
			self.navigationController.view.frame = frame;
		}];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.backgroundSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kAnonyFollowBackgroundScanEnabled];
	self.showFollowingSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kAnonyFollowDebugShowFollowingUsers];
	self.showRedundantSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kAnonyFollowDebugShowRedundantUsers];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// version string
	self.versionCell.detailTextLabel.text = [[UIApplication sharedApplication] versionString];
	
	// application name
	self.applicationNameCell.detailTextLabel.text = [[UIApplication sharedApplication] applicationNameForDisplay];
}

#pragma mark - MFMailComposeViewController

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissViewControllerAnimated:YES completion:^{
		DNSLog(@"dismissModalViewControllerAnimated completed!")
	}];
}

#pragma mark - UITableViewDelegate/DataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 4) {
		[self sendFeedbackMail];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#ifdef _DEBUG
#else
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
#endif

@end
