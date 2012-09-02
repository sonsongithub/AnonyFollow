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

@class LockScreenView;
@class CBScanner;
@class CBAdvertizer;
@class MessageBarButtonItem;

@interface MainListViewController : UITableViewController <CBScannerDelegate, CBAdvertizerDelegate>

- (IBAction)trash:(id)sender;
- (IBAction)select:(id)sender;
- (IBAction)follow:(id)sender;

@property (strong, nonatomic) IBOutlet LockScreenView *lockScreenView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet MessageBarButtonItem *twitterAccountButton;

@property (nonatomic, strong) NSMutableArray *accounts;

@property (strong, nonatomic) CBScanner *scanner;
@property (strong, nonatomic) CBAdvertizer *advertizer;

@end
