//
//  AppDelegate.h
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNStatusBarView;
@class SNReachablityChecker;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SNStatusBarView *barView;
@property (strong, nonatomic) SNReachablityChecker *checker;

@end
