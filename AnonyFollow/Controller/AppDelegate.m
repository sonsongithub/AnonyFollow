//
//  AppDelegate.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import "AppDelegate.h"

#import "SNStatusBarView.h"
#import "SNReachablityChecker.h"
#import "NSString+AnonyFollow.h"
#import "NSUserDefaults+AnonyFollow.h"

@implementation AppDelegate

- (void)setupOriginalStatusBar {
	if (self.barView == nil) {
		self.barView = [[SNStatusBarView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
		self.checker = [SNReachablityChecker reachabilityForInternetConnection];
		[self.checker start];
		[self.window addSubview:self.barView];
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithBool:NO],	kAnonyFollowBackgroundScanEnabled,
								[NSNumber numberWithBool:NO],	kAnonyFollowDebugShowFollowingUsers,
								@"",							kAnonyFollowCurrentTwitterUserName,
								nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
	[[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

@end
