//
//  SettingViewController.h
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>

@interface SettingViewController : UITableViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) int versionClickCount;
@property (nonatomic, strong) IBOutlet UITableViewCell *applicationNameCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *versionCell;
@property (nonatomic, strong) IBOutlet UISwitch *backgroundSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *tweetOnBackgroundSwitch;

- (IBAction)didChangeBackgroundSwitch:(id)sender;
- (IBAction)didChangeTweetOnBackgroundSwitch:(id)sender;

// for debug
@property (nonatomic, strong) IBOutlet UISwitch *showFollowingSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *showRedundantSwitch;
- (IBAction)didChangeShowFollowingSwitch:(id)sender;
- (IBAction)didChangeShowRedundantSwitch:(id)sender;

@end
