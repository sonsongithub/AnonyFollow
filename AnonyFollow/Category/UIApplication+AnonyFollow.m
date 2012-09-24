//
//  UIApplication+AnonyFollow.m
//  AnonyFollow
//
//  Created by sonson on 2012/09/25.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "UIApplication+AnonyFollow.h"

#import "NSBundle+AnonyFollow.h"

@implementation UIApplication(AnonyFollow)

- (NSString*)versionString {
	// version string
	NSString *CFBundleShortVersionString = [NSBundle infoValueFromMainBundleForKey:@"CFBundleShortVersionString"];
	NSString *CFBundleVersion = [NSBundle infoValueFromMainBundleForKey:@"CFBundleVersion"];
	NSString *CFBundleGitRevision = [NSBundle infoValueFromMainBundleForKey:@"CFBundleGithubShortRevision"];
	return [NSString stringWithFormat:@"%@.%@.%@", CFBundleShortVersionString, CFBundleVersion,  CFBundleGitRevision];
}

- (NSString*)applicationNameForDisplay {
	// application name
#if defined(_TESTFLIGHT)
	return [NSString stringWithFormat:@"%@(TestFlight)", [NSBundle infoValueFromMainBundleForKey:@"CFBundleDisplayName"]];
#elif defined(_DEBUG)
	return [NSString stringWithFormat:@"%@(Debug)", [NSBundle infoValueFromMainBundleForKey:@"CFBundleDisplayName"]];
#else
	return [NSBundle infoValueFromMainBundleForKey:@"CFBundleDisplayName"];
#endif
}

@end