//
//  ACAccountStore+AnonyFollow.h
//  AnonyFollow
//
//  Created by sonson on 2012/09/02.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <Accounts/Accounts.h>


@interface ACAccountStore(AnonyFollow)

- (NSString*)twitterAvailableUserName;
- (ACAccount*)twitterCurrentAccount;

@end
