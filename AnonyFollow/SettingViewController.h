//
//  SettingViewController.h
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FriendsDownloader;

@interface SettingViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UITableViewCell *applicationNameCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *versionCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *timerCell;

@property (nonatomic, strong) FriendsDownloader *downloader;

@end
