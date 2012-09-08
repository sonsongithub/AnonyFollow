//
//  ACAccountStore+AnonyFollow.m
//  AnonyFollow
//
//  Created by sonson on 2012/09/02.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "ACAccountStore+AnonyFollow.h"

#import "NSUserDefaults+AnonyFollow.h"

@implementation ACAccountStore(AnonyFollow)

- (NSString*)twitterAvailableUserName {
	NSArray *accountsArray = [self accountsWithAccountType:[self accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];
	
	NSString *currentTwitterUserName = [[NSUserDefaults standardUserDefaults] objectForKey:kAnonyFollowCurrentTwitterUserName];
	
	for (ACAccount *account in accountsArray) {
		if ([currentTwitterUserName length]) {
			if ([account.username isEqualToString:currentTwitterUserName])
				return currentTwitterUserName;
		}
		else {
			[[NSUserDefaults standardUserDefaults] setObject:account.username forKey:kAnonyFollowCurrentTwitterUserName];
			[[NSUserDefaults standardUserDefaults] synchronize];
			return account.username;
		}
	}
	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kAnonyFollowCurrentTwitterUserName];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return nil;
}

- (ACAccount*)twitterCurrentAccount {
	NSArray *accountsArray = [self accountsWithAccountType:[self accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter]];
	
	NSString *currentTwitterUserName = [[NSUserDefaults standardUserDefaults] objectForKey:kAnonyFollowCurrentTwitterUserName];
	
	for (ACAccount *account in accountsArray) {
		if ([currentTwitterUserName length]) {
			if ([account.username isEqualToString:currentTwitterUserName]) {
				return account;
			}
		}
		else {
			[[NSUserDefaults standardUserDefaults] setObject:account.username forKey:kAnonyFollowCurrentTwitterUserName];
			[[NSUserDefaults standardUserDefaults] synchronize];
			return account;
		}
	}
	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kAnonyFollowCurrentTwitterUserName];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return nil;
}

@end