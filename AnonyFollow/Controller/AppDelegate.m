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
		UIScreen *screen = [UIScreen mainScreen];
		CGSize size = screen.bounds.size;
		size.height = [UIApplication sharedApplication].statusBarFrame.size.height;
		CGRect frame = CGRectMake(0, 0, size.width, size.height);
		
		self.barView = [[SNStatusBarView alloc] initWithFrame:frame];
		self.checker = [SNReachablityChecker reachabilityForInternetConnection];
		[self.checker start];
		[self.window addSubview:self.barView];
		[self.window sendSubviewToBack:self.barView];
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef _DEBUG
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithBool:NO],	kAnonyFollowBackgroundScanEnabled,
								[NSNumber numberWithBool:NO],	kAnonyFollowDebugShowFollowingUsers,
								[NSNumber numberWithBool:NO],	kAnonyFollowDebugShowRedundantUsers,
								@"",							kAnonyFollowCurrentTwitterUserName,
								nil];
#else
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithBool:NO],	kAnonyFollowBackgroundScanEnabled,
								[NSNumber numberWithBool:NO],	kAnonyFollowDebugShowFollowingUsers,
								[NSNumber numberWithBool:NO],	kAnonyFollowDebugShowRedundantUsers,
								@"",							kAnonyFollowCurrentTwitterUserName,
								nil];
#endif
	[[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
	[[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
	DNSLogMethod
}

@end
