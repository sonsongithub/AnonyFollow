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

- (IBAction)didChangeBackgroundSwitch:(id)sender {
	if (sender == self.backgroundSwitch) {
		[[NSUserDefaults standardUserDefaults] setBool:self.backgroundSwitch.on forKey:kAnonyFollowBackgroundScanEnabled];
		[[NSUserDefaults standardUserDefaults] synchronize];
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

#ifdef _DEBUG
#else
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
#endif

@end
