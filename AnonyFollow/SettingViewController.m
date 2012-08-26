//
//  SettingViewController.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import "SettingViewController.h"

#import "TimerLengthController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (IBAction)dismiss:(id)sender {
	[self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated {
	if ([UIApplication sharedApplication].statusBarHidden) {
		[UIView animateWithDuration:0.4 animations:^(void){
	[super viewDidAppear:animated];self.navigationController.view.frame = CGRectMake(0, 20, 320, 460);
	
	}];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.timerCell.detailTextLabel.text = [TimerLengthController currentTimerLengthTitle];
}

@end
