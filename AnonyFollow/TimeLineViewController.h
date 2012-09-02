//
//  TimeLineViewController.h
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TwitterAccountInfo;

@interface TimeLineViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, strong) TwitterAccountInfo *accountInfo;

- (IBAction)follow:(id)sender;

@end
