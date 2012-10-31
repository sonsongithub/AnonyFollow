//
//  HistoryViewController.h
//  AnonyFollow
//
//  Created by sonson on 2012/10/31.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AccountsListViewController.h"
#import "TwitterAccountInfo.h"

@interface HistoryViewController : AccountsListViewController <MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *baseViewHeightConstraint;
@property (nonatomic, strong) TwitterAccountInfo *savedAccountInfo;
@property (nonatomic, assign) BOOL isAlreadyLoadded;

@end
