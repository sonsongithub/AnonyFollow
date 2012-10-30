//
//  AccountsListViewController.h
//  AnonyFollow
//
//  Created by sonson on 2012/10/26.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface AccountsListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ADBannerViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *accounts;

@property (nonatomic, strong) IBOutlet ADBannerView *bannerView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *constraint;

- (void)loadImagesForOnscreenRows;

@end
