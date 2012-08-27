//
//  AppDelegate.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
	self.barView = [[SNStatusBarView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
	[self.window addSubview:self.barView];
	
    return YES;
}

@end
