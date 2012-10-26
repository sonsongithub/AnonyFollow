//
//  MainListViewController.h
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AccountsListViewController.h"

#import "CBAdvertizer.h"
#import "CBScanner.h"

#import <CoreLocation/CoreLocation.h>

extern NSString *kNotificationDidFollowUser;
extern NSString *kNotificationUserInfoUserNameKey;

@class CBScanner;
@class CBAdvertizer;
@class MessageBarButtonItem;

@interface MainListViewController : AccountsListViewController <CLLocationManagerDelegate, CBScannerDelegate, CBAdvertizerDelegate, UIActionSheetDelegate>

- (IBAction)trash:(id)sender;
- (IBAction)select:(id)sender;
- (IBAction)follow:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *lockScreenView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet MessageBarButtonItem *twitterAccountButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *trashButton;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;

@property (nonatomic, strong) NSMutableArray *history;

@property (strong, nonatomic) CBScanner *scanner;
@property (strong, nonatomic) CBAdvertizer *advertizer;

@end
