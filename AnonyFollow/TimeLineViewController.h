//
//  TimeLineViewController.h
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TwitterAccountInfo;
@class LoadingView;

@interface TimeLineViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, strong) TwitterAccountInfo *accountInfo;
@property (nonatomic, strong) IBOutlet LoadingView *loadingView;

- (IBAction)follow:(id)sender;

@end
