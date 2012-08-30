//
//  SettingViewController.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import "SettingViewController.h"

#import "TimerLengthController.h"

@interface UIViewController(SettingViewController)

- (IBAction)dismiss:(id)sender;

@end

@implementation UIViewController(SettingViewController)

- (IBAction)dismiss:(id)sender {
	if ([UIApplication sharedApplication].statusBarHidden) {
		[UIView animateWithDuration:0.4
						 animations:^(void) {
							 self.navigationController.view.frame = CGRectMake(0, 0, 320, 480);
						 }
						 completion:^(BOOL success) {
							 [self dismissViewControllerAnimated:YES completion:^(void){}];
						 }];
	}
	else {
		[self dismissViewControllerAnimated:YES completion:^(void){}];
	}
}
@end

@interface SettingViewController ()

@end

@implementation NSBundle(SettingViewController)

+ (id)infoValueFromMainBundleForKey:(NSString*)key {
	if ([[[self mainBundle] localizedInfoDictionary] objectForKey:key])
		return [[[self mainBundle] localizedInfoDictionary] objectForKey:key];
	return [[[self mainBundle] infoDictionary] objectForKey:key];
}

@end

@implementation SettingViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([UIApplication sharedApplication].statusBarHidden) {
		[UIView animateWithDuration:0.4 animations:^(void){
			self.navigationController.view.frame = CGRectMake(0, 20, 320, 460);
		}];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSString *CFBundleShortVersionString = [NSBundle infoValueFromMainBundleForKey:@"CFBundleShortVersionString"];
	NSString *CFBundleVersion = [NSBundle infoValueFromMainBundleForKey:@"CFBundleVersion"];
	NSString *CFBundleGitRevision = [NSBundle infoValueFromMainBundleForKey:@"CFBundleGithubShortRevision"];
	
	self.versionCell.detailTextLabel.text = [NSString stringWithFormat:@"%@.%@.%@", CFBundleShortVersionString, CFBundleVersion,  CFBundleGitRevision];
		
	self.applicationNameCell.detailTextLabel.text = [NSBundle infoValueFromMainBundleForKey:@"CFBundleDisplayName"];
	self.timerCell.detailTextLabel.text = [TimerLengthController currentTimerLengthTitle];
}

@end
