//
//  NSBundle+AnonyFollow.m
//  AnonyFollow
//
//  Created by sonson on 2012/09/08.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "NSBundle+AnonyFollow.h"

@implementation NSBundle(AnonyFollow)

+ (id)infoValueFromMainBundleForKey:(NSString*)key {
	if ([[[self mainBundle] localizedInfoDictionary] objectForKey:key])
		return [[[self mainBundle] localizedInfoDictionary] objectForKey:key];
	return [[[self mainBundle] infoDictionary] objectForKey:key];
}

@end
