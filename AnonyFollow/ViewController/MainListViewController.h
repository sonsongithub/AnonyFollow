//
//  MainListViewController.h
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CBAdvertizer.h"
#import "CBScanner.h"

extern NSString *kNotificationDidFollowUser;
extern NSString *kNotificationUserInfoUserNameKey;

@class LockScreenView;
@class CBScanner;
@class CBAdvertizer;
@class MessageBarButtonItem;

@interface MainListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CBScannerDelegate, CBAdvertizerDelegate, UIActionSheetDelegate>

- (IBAction)trash:(id)sender;
- (IBAction)select:(id)sender;
- (IBAction)follow:(id)sender;

@property (strong, nonatomic) IBOutlet LockScreenView *lockScreenView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet MessageBarButtonItem *twitterAccountButton;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *accounts;
@property (nonatomic, strong) NSMutableArray *accountsCollectedOnBackground;

@property (strong, nonatomic) CBScanner *scanner;
@property (strong, nonatomic) CBAdvertizer *advertizer;

@end
