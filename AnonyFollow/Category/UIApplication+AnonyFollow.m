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
	// application name
#if defined(_TESTFLIGHT)
	return [NSString stringWithFormat:@"%@(TestFlight)", [NSBundle infoValueFromMainBundleForKey:@"CFBundleShortVersionString"]];
#elif defined(_DEBUG)
	return [NSString stringWithFormat:@"%@(Debug)", [NSBundle infoValueFromMainBundleForKey:@"CFBundleShortVersionString"]];
#else
	return [NSBundle infoValueFromMainBundleForKey:@"CFBundleShortVersionString"];
#endif
}

- (NSString*)buildNumberString {
	return [NSBundle infoValueFromMainBundleForKey:@"CFBundleVersion"];
}

- (NSString*)revisionString {
	return [NSBundle infoValueFromMainBundleForKey:@"CFBundleGithubShortRevision"];
}

- (NSString*)applicationInformationString {
	return [NSString stringWithFormat:@"%@.%@.%@", [self versionString], [self buildNumberString],  [self revisionString]];
}

- (NSString*)applicationNameForDisplay {
	return [NSBundle infoValueFromMainBundleForKey:@"CFBundleDisplayName"];
}

@end